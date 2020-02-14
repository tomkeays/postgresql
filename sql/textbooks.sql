SELECT
  b.record_type_code || b.record_num AS "bib_num",
  i.barcode,
  m.best_title AS "title",
  m.best_author AS "author",
  m.publish_year AS "year",
  UPPER(p.call_number_norm) AS "call_number",
  i.checkout_total AS "total_checkout",
  i.renewal_total AS "total_renewals",
  i.last_year_to_date_checkout_total AS "last_year_checkout",
  i.year_to_date_checkout_total AS "ytd_checkout",
  i.last_checkin_gmt::DATE AS "last_checkin",
  i.location_code,
  b.cataloging_date_gmt::DATE AS "cat_date",
  b.record_creation_date_gmt::DATE AS "creation_date"
FROM
  sierra_view.item_view i
JOIN
  sierra_view.bib_record_item_record_link l ON l.item_record_id = i.id
JOIN
  sierra_view.bib_view b ON l.bib_record_id = b.id
JOIN
  sierra_view.bib_record_property m ON m.bib_record_id = b.id
JOIN
  sierra_view.item_record_property p ON p.item_record_id = i.id
WHERE
  i.location_code = 'lrsvt'
  AND p.call_number_norm IS NOT NULL
ORDER BY
  p.call_number_norm ASC,
  b.record_num ASC
;
