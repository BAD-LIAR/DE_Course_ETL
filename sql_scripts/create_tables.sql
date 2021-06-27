CREATE TABLE ITDE1.NIGV_META_LOADING (
    DBNAME VARCHAR2(20),
    TABLENAME VARCHAR2(40),
    LAST_UPDATE date
);

create table itde1.nigv_stg_terminals_all(
    terminal_id varchar2(60),
    terminal_type varchar2(60),
    terminal_city varchar2(60),
    terminal_address varchar2(200),
    create_dt date,
    update_dt date
);

insert into ITDE1.NIGV_META_LOADING(dbname, tablename, last_update) values ('ITDE1', 'nigv_stg_account', to_date('01.01.1899 00:00:00'));
insert into ITDE1.NIGV_META_LOADING(dbname, tablename, last_update) values ('ITDE1', 'nigv_stg_cards', to_date('01.01.1899 00:00:00'));
insert into ITDE1.NIGV_META_LOADING(dbname, tablename, last_update) values ('ITDE1', 'nigv_stg_clients', to_date('01.01.1899 00:00:00'));
insert into ITDE1.NIGV_META_LOADING(dbname, tablename, last_update) values ('ITDE1', 'nigv_stg_terminals', to_date('01.01.1899 00:00:00'));



create table ITDE1.NIGV_DWH_DIM_clients(
    client_id varchar2(60),
    last_name varchar2(60),
    first_name varchar2(60),
    patronymic varchar2(60),
    date_of_birth date,
    passport_num varchar2(60),
    passport_valid_to date,
    phone varchar2(60),
    create_dt date,
    update_dt date
);

create table ITDE1.NIGV_DWH_DIM_accounts(
    account_num varchar2(60),
    valid_to date,
    client varchar2(60),
    create_dt date,
    update_dt date
);

create table ITDE1.NIGV_DWH_DIM_cards(
    card_num varchar2(60),
    account_num varchar2(60),
    create_dt date,
    update_dt date
);


create table ITDE1.NIGV_DWH_DIM_terminals(
    terminal_id varchar2(60),
    terminal_type varchar2(60),
    terminal_city varchar2(60),
    terminal_address varchar2(200),
    create_dt date,
    update_dt date
);

create table ITDE1.NIGV_DWH_FACT_pssprt_blcklst(
    passport_num varchar2(60),
    entry_dt date
);

create table ITDE1.NIGV_DWH_FACT_transactions(
    trains_id varchar2(60),
    trans_date date,
    card_num varchar2(60),
    oper_type varchar2(60),
    amt numeric(10, 2),
    oper_result varchar2(60),
    terminal varchar2(60)
);



-------------------------------------------------------------------

create table ITDE1.NIGV_STG_clients(
    client_id varchar2(60),
    last_name varchar2(60),
    first_name varchar2(60),
    patronymic varchar2(60),
    date_of_birth date,
    passport_num varchar2(60),
    passport_valid_to date,
    phone varchar2(60),
    create_dt date,
    update_dt date
);

create table ITDE1.NIGV_STG_account(
    account_num varchar2(60),
    valid_to date,
    client varchar2(60),
    create_dt date,
    update_dt date
);

create table ITDE1.NIGV_STG_cards(
    card_num varchar2(60),
    account_num varchar2(60),
    create_dt date,
    update_dt date
);

create table ITDE1.NIGV_STG_terminals(
    terminal_id varchar2(60),
    terminal_type varchar2(60),
    terminal_city varchar2(60),
    terminal_address varchar2(200),
    create_dt date,
    update_dt date
);

create table ITDE1.NIGV_STG_pssprt_blcklst(
    passport_num varchar2(60),
    entry_dt date
);


CREATE TABLE ITDE1.NIGV_META_LOADING (
    DBNAME VARCHAR2(20),
    TABLENAME VARCHAR2(20)
);

create table ITDE1.NIGV_REP_FRAUD(
    event_dt date,
    passport varchar2(60),
    fio varchar2(60),
    phone varchar2(60),
    event_type varchar2(2),
    report_dt date
);