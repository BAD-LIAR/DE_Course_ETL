delete from itde1.nigv_dwh_dim_account;
delete from itde1.nigv_dwh_dim_cards;
delete from itde1.nigv_dwh_dim_clients;
delete from itde1.nigv_dwh_dim_terminals;
delete from itde1.nigv_dwh_fact_pssprt_blcklst;
delete from itde1.nigv_dwh_fact_transactions;
delete from itde1.nigv_stg_terminals_all;

delete from itde1.NIGV_META_LOADING;

insert into ITDE1.NIGV_META_LOADING(dbname, tablename, last_update) values ('ITDE1', 'nigv_stg_account', to_date('01.01.1899 00:00:00'));
insert into ITDE1.NIGV_META_LOADING(dbname, tablename, last_update) values ('ITDE1', 'nigv_stg_cards', to_date('01.01.1899 00:00:00'));
insert into ITDE1.NIGV_META_LOADING(dbname, tablename, last_update) values ('ITDE1', 'nigv_stg_clients', to_date('01.01.1899 00:00:00'));
insert into ITDE1.NIGV_META_LOADING(dbname, tablename, last_update) values ('ITDE1', 'nigv_stg_terminals', to_date('01.01.1899 00:00:00'));