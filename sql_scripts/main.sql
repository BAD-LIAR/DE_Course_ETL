-- Выполяем инкрементальную загрузку

-- начало транзакции

-- 1. Очистка данных из STG
delete from itde1.nigv_stg_account;
delete from itde1.nigv_stg_cards;
delete from itde1.nigv_stg_clients;
delete from itde1.nigv_stg_pssprt_blcklst;
delete from itde1.nigv_stg_terminals;

-- 2. Захват данных из источника в STG

INSERT INTO itde1.nigv_stg_account(account_num, valid_to, client, create_dt, update_dt)
SELECT
	account, valid_to, client, create_dt, coalesce(update_dt, create_dt)
FROM BANK.accounts
WHERE coalesce(update_dt, create_dt) > (
	SELECT LAST_UPDATE FROM ITDE1.NIGV_META_LOADING WHERE DBNAME = 'ITDE1' AND TABLENAME = 'nigv_stg_account'
);

INSERT INTO itde1.nigv_stg_cards(card_num, account_num, create_dt, update_dt)
SELECT
	card_num, account, create_dt, coalesce(update_dt, create_dt)
FROM BANK.cards
WHERE coalesce(update_dt, create_dt) > (
	SELECT LAST_UPDATE FROM ITDE1.NIGV_META_LOADING WHERE DBNAME = 'ITDE1' AND TABLENAME = 'nigv_stg_cards'
);

INSERT INTO itde1.nigv_stg_clients(client_id, last_name, first_name, patronymic, date_of_birth, passport_num, passport_valid_to, phone, create_dt, update_dt)
SELECT
	client_id, last_name, first_name, patronymic, date_of_birth, passport_num, passport_valid_to, phone, create_dt, coalesce(update_dt, create_dt)
FROM BANK.clients
WHERE coalesce(update_dt, create_dt) > (
	SELECT LAST_UPDATE FROM ITDE1.NIGV_META_LOADING WHERE DBNAME = 'ITDE1' AND TABLENAME = 'nigv_stg_clients'
);

INSERT INTO itde1.nigv_stg_terminals(terminal_id, terminal_type, terminal_city, terminal_address, create_dt, update_dt)
SELECT
	terminal_id, terminal_type, terminal_city, terminal_address, create_dt, coalesce(update_dt, create_dt)
FROM itde1.nigv_stg_terminals_all
WHERE coalesce(update_dt, create_dt) > (
	SELECT LAST_UPDATE FROM ITDE1.NIGV_META_LOADING WHERE DBNAME = 'ITDE1' AND TABLENAME = 'nigv_stg_terminals'
);





-- 3. Обновляем обновленные строки в хранилище



-- Загрузка измерений

MERGE INTO ITDE1.nigv_dwh_dim_accounts tgt
USING itde1.nigv_stg_account stg
ON ( tgt.account_num = stg.account_num )
WHEN MATCHED THEN UPDATE SET
	tgt.valid_to = stg.valid_to,
	tgt.client = stg.client,
	tgt.update_dt = stg.update_dt
WHEN NOT MATCHED THEN INSERT ( account_num,valid_to,client,create_dt,update_dt )
    VALUES ( stg.account_num, stg.valid_to, stg.client, stg.CREATE_DT, stg.UPDATE_DT );


MERGE INTO ITDE1.nigv_dwh_dim_cards tgt
USING itde1.nigv_stg_cards stg
ON ( tgt.card_num = stg.card_num )
WHEN MATCHED THEN UPDATE SET
	tgt.account_num = stg.account_num,
	tgt.update_dt = stg.update_dt
WHEN NOT MATCHED THEN INSERT ( card_num,account_num, create_dt,update_dt )
    VALUES ( stg.card_num, stg.account_num, stg.CREATE_DT, stg.UPDATE_DT );

MERGE INTO ITDE1.nigv_dwh_dim_clients tgt
USING itde1.nigv_stg_clients stg
ON ( tgt.client_id = stg.client_id )
WHEN MATCHED THEN UPDATE SET
	tgt.last_name = stg.last_name,
	tgt.first_name = stg.first_name,
	tgt.patronymic = stg.patronymic,
    tgt.date_of_birth = stg.date_of_birth,
	tgt.passport_num = stg.passport_num,
	tgt.passport_valid_to = stg.passport_valid_to,
    tgt.phone = stg.phone,
	tgt.update_dt = stg.update_dt
WHEN NOT MATCHED THEN INSERT (client_id, last_name, first_name, patronymic, date_of_birth, passport_num, passport_valid_to, phone, create_dt, update_dt)
    VALUES (stg.client_id, stg.last_name, stg.first_name, stg.patronymic, stg.date_of_birth, stg.passport_num, stg.passport_valid_to, stg.phone, stg.create_dt, stg.update_dt);


MERGE INTO ITDE1.nigv_dwh_dim_terminals tgt
USING itde1.nigv_stg_terminals stg
ON ( tgt.terminal_id = stg.terminal_id )
WHEN MATCHED THEN UPDATE SET
	tgt.terminal_type = stg.terminal_type,
	tgt.terminal_city = stg.terminal_city,
	tgt.terminal_address = stg.terminal_address,
    tgt.update_dt = stg.update_dt
WHEN NOT MATCHED THEN INSERT (terminal_id, terminal_type, terminal_city, create_dt, update_dt)
    VALUES (stg.terminal_id, stg.terminal_type, stg.terminal_city, stg.create_dt, stg.update_dt);


insert into ITDE1.NIGV_REP_FRAUD (event_dt, passport, fio, phone, event_type, report_dt)
select trans_date, passport_num, CONCAT(CONCAT(first_name, last_name), patronymic),  phone, '1' as event_type, CURRENT_DATE from itde1.NIGV_DWH_FACT_transactions tr
    join itde1.NIGV_DWH_DIM_cards cr on trim(tr.card_num) = trim(cr.card_num)
    join itde1.NIGV_DWH_DIM_accounts ac on cr.account_num = ac.account_num
    join itde1.NIGV_DWH_DIM_clients cli on ac.client = cli.client_id
    where passport_valid_to < trans_date
    or passport_num in (select passport_num from ITDE1.NIGV_DWH_FACT_pssprt_blcklst)
;

insert into ITDE1.NIGV_REP_FRAUD (event_dt, passport, fio, phone, event_type, report_dt)
select trans_date, passport_num, CONCAT(CONCAT(first_name, last_name), patronymic),  phone, '2' as event_type, CURRENT_DATE from itde1.NIGV_DWH_FACT_transactions tr
    join itde1.NIGV_DWH_DIM_cards cr on trim(tr.card_num) = trim(cr.card_num)
    join itde1.NIGV_DWH_DIM_accounts ac on cr.account_num = ac.account_num
    join itde1.NIGV_DWH_DIM_clients cli on ac.client = cli.client_id
    where  ac.valid_to < trans_date
;

-- 4. Обновляем метаданные - дату максимальной загрузуки
UPDATE ITDE1.NIGV_META_LOADING
SET LAST_UPDATE = ( SELECT MAX( CREATE_DT ) FROM ITDE1.nigv_stg_account )
WHERE 1=1
	AND DBNAME = 'ITDE1'
	AND TABLENAME = 'nigv_stg_account'
	AND ( SELECT MAX( CREATE_DT ) FROM ITDE1.nigv_stg_account ) IS NOT NULL;

UPDATE ITDE1.NIGV_META_LOADING
SET LAST_UPDATE = ( SELECT MAX( CREATE_DT ) FROM ITDE1.nigv_stg_cards )
WHERE 1=1
	AND DBNAME = 'ITDE1'
	AND TABLENAME = 'nigv_stg_cards'
	AND ( SELECT MAX( CREATE_DT ) FROM ITDE1.nigv_stg_cards ) IS NOT NULL;

UPDATE ITDE1.NIGV_META_LOADING
SET LAST_UPDATE = ( SELECT MAX( CREATE_DT ) FROM ITDE1.nigv_stg_clients )
WHERE 1=1
	AND DBNAME = 'ITDE1'
	AND TABLENAME = 'nigv_stg_clients'
	AND ( SELECT MAX( CREATE_DT ) FROM ITDE1.nigv_stg_clients ) IS NOT NULL;

UPDATE ITDE1.NIGV_META_LOADING
SET LAST_UPDATE = ( SELECT MAX( CREATE_DT ) FROM ITDE1.nigv_stg_terminals )
WHERE 1=1
	AND DBNAME = 'ITDE1'
	AND TABLENAME = 'nigv_stg_terminals'
	AND ( SELECT MAX( CREATE_DT ) FROM ITDE1.nigv_stg_terminals ) IS NOT NULL;




-- 5. Фиксируется транзакция
COMMIT


