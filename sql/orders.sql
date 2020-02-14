SELECT 
 m.best_title AS "title",
 m.best_author AS "author",
 m.publish_year AS "year",
 TRUNC(o.estimated_price, 2) AS "price",
 DATE(o.order_date_gmt) AS "order_date"
FROM
 sierra_view.order_view o
JOIN
 sierra_view.bib_record_order_record_link l ON l.order_record_id = o.id
JOIN
 sierra_view.bib_view b ON l.bib_record_id = b.id
JOIN
 sierra_view.bib_record_property m ON m.bib_record_id = b.id
WHERE
 o.order_status_code = 'o' -- on order
AND
 o.order_type_code = 'f' -- firm order