import pandas as pd
import jaydebeapi
import glob
import os

passport = glob.glob('passport*')
path = passport[0]
passports = pd.read_excel(path, header=0, index_col=None)


terminal = glob.glob('terminals*')
path_terminal = terminal[0]
terminals = pd.read_excel(path_terminal, header=0, index_col=None)

transaction = glob.glob('transactions*')
path_tansaction = transaction[0]
transactions = pd.read_csv(path_tansaction, header=0, index_col=None, delimiter=';', decimal=',')
transactions = transactions.astype({"transaction_id": 'str'})
transactions = transactions.astype({'transaction_date': 'str'})
# transactions = transactions.astype({'amount': 'float64'})

date_from_path = path_tansaction.split('_')[1].split('.')[0]
date = date_from_path[0] + date_from_path[1] + '.' + date_from_path[2] + date_from_path[3] + '.' + date_from_path[4] + date_from_path[5] + date_from_path[6] + date_from_path[7]



conn = jaydebeapi.connect(
    'oracle.jdbc.driver.OracleDriver',
    'jdbc:oracle:thin:itde1/bilbobaggins@de-oracle.chronosavant.ru:1521/deoracle',
    ['itde1', 'bilbobaggins'],
    'ojdbc8.jar')
conn.jconn.setAutoCommit(False)
curs = conn.cursor()
for index, row in terminals.iterrows():
    sql = "insert into itde1.nigv_stg_terminals_all (terminal_id, terminal_type, terminal_city, terminal_address, create_dt, update_dt) values(?, ?, ?, ?, to_date(?, 'DD.MM.YYYY'), to_date(?, 'DD.MM.YYYY'))"
    curs.execute(sql, (row['terminal_id'], row['terminal_type'], row['terminal_city'], row['terminal_address'], date, date))
print('inserted terminals')

for index, row in passports.iterrows():
    sql = "insert into ITDE1.NIGV_DWH_FACT_pssprt_blcklst (entry_dt, passport_num) values(to_date(?, 'YYYY-MM-DD HH24:mi:ss'), ?)"
    curs.execute(sql, (str(row['date']), row['passport']))
print('inserted passports')
print(transactions.values[1])
# for index, row in transactions.iterrows():
#     print(row)
#     sql = "insert into ITDE1.NIGV_DWH_FACT_transactions (trains_id, trans_date, card_num, oper_type, amt, oper_result, terminal) values(?, to_date(?, 'YYYY-MM-DD HH24:mi:ss'), ?, ?, ?, ?, ?)"
#     curs.execute(sql, (str(row['transaction_id']), str(row['transaction_date']), str(row['card_num']), str(row['oper_type']), str(row['amount']), str(row['oper_result']), str(row['terminal'])))

sql = "insert into ITDE1.NIGV_DWH_FACT_transactions (trains_id, trans_date, amt, card_num, oper_type, oper_result, terminal) values(?, to_date(?, 'YYYY-MM-DD HH24:mi:ss'), ?, ?, ?, ?, ?)"
curs.executemany(sql, transactions.values)


f = open("sql_scripts/main.sql")
sql = f.read()
arr = sql.split(';')
for s in arr:
    print(s)
    curs.execute(s)
# print('inserted transactions')
print(path, "archive/" + path + ".backup")
os.replace(path, "archive/" + path + ".backup")
os.replace(path_tansaction, "archive/" + path_tansaction + ".backup")
os.replace(path_terminal, "archive/" + path_terminal + ".backup")
conn.commit()
curs.close()
conn.close()
# curs.execute("TRUNCATE TABLE itde1.nigv_stg_terminals_all")
# conn.commit()




