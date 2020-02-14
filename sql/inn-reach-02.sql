SELECT 
	h.status AS "Hold Status",
	p.record_type_code || p.record_num AS "Patron ID",
	p.barcode AS "Barcode",
	n.first_name AS "First Name",
	n.last_name AS "Last Name",
	i.record_type_code || i.record_num AS "Item Number"
FROM
	sierra_view.hold h
	JOIN sierra_view.patron_view p ON p.id = h.patron_record_id
	JOIN sierra_view.patron_record_fullname n ON p.id = n.patron_record_id
	JOIN sierra_view.request r ON p.id = r.patron_record_id
	JOIN sierra_view.item_view i ON i.id = r.item_record_id
WHERE h.is_ir IS TRUE
ORDER BY n.last_name ASC
LIMIT 100;
