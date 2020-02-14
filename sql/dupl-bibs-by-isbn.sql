-- Duplicate bibs by standard number index

SELECT
    id2reckey(p.record_id)||'a' AS bib_number,
    p.index_entry AS isbn
 
FROM
    sierra_view.phrase_entry as p
JOIN
    sierra_view.bib_record as b
ON
    p.record_id=b.record_id
 
WHERE
    p.index_entry IN (
        SELECT
            p.index_entry
        FROM
            sierra_view.phrase_entry as p
        WHERE
            p.index_tag = 'i'
        GROUP BY
            p.index_entry
        HAVING
            count(p.id) > 1)
 
ORDER BY
    isbn, bib_number 
