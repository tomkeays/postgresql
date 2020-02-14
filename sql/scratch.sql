SELECT
b.record_type_code || b.record_num AS "bib_num",
i.record_type_code || i.record_num AS "item_num",
i.barcode,
b.title,
i.checkout_total,
i.last_checkin_gmt,
i.price,
b.is_on_course_reserve AS on_reserve,
i.location_code AS item_location_code,
'https://library.lemoyne.edu/record=' || b.record_type_code || b.record_num AS "catalog_url"
FROM
sierra_view.item_view i
LEFT JOIN sierra_view.bib_record_item_record_link l ON i.id = l.item_record_id
LEFT JOIN sierra_view.bib_view b ON b.id = l.bib_record_id
WHERE
i.price > 0 
AND b.is_on_course_reserve IS TRUE
ORDER BY i.checkout_total DESC
LIMIT 200;