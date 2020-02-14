SELECT 
	h.status AS "Hold Status",
	p.record_type_code || p.record_num AS "Patron ID",
	p.barcode AS "Barcode",
	n.first_name,
	n.last_name
FROM
	sierra_view.hold h
	JOIN sierra_view.patron_view p ON p.id = h.patron_record_id
	JOIN sierra_view.patron_record_fullname n ON p.id = n.patron_record_id
WHERE h.is_ir IS TRUE
ORDER BY n.last_name ASC
LIMIT 100;
