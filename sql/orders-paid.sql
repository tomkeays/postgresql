SELECT 
  UPPER(fm.code) AS "fund_code",
  TRUNC(SUM(orp.paid_amount), 2) AS "expenditure", -- amounts match WMR expenditure !!!
  TRUNC(SUM(inv.paid_amt), 2) AS "invoice paid"    -- doesn't match WMR encumbrance; what does?
  FROM sierra_view.order_record_paid orp
JOIN sierra_view.order_record_cmf orc ON orc.order_record_id=orp.order_record_id
JOIN sierra_view.invoice_record_line inv ON inv.order_record_metadata_id = orp.order_record_id
JOIN sierra_view.fund_master fm ON fm.code_num=CAST(orc.fund_code AS INTEGER)
WHERE orp.paid_date_gmt::date between '2019-06-01' AND '2020-05-31'
AND UPPER(fm.code) LIKE 'BK%'
GROUP BY fm.code
ORDER BY fm.code
