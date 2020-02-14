-- Bib records without attached items

SELECT
  id2reckey(b.bib_record_id)||'a' AS "bib_num"
 
FROM
  sierra_view.bib_record_property b
 
WHERE
  NOT EXISTS
    (SELECT
       l.bib_record_id
     FROM
       sierra_view.bib_record_item_record_link l
     WHERE
       l.bib_record_id = b.bib_record_id)
;