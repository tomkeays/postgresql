SELECT
    b.record_type_code || b.record_num AS "Bib Record",
    b.title  AS "Title", 
    SUBSTRING (sub1.field_content FROM 3 FOR 40) AS "Dupl Subject"
FROM 
    sierra_view.bib_view b
    JOIN  sierra_view.varfield_view sub1 ON b.id = sub1.record_id 
                                        AND sub1.varfield_type_code = 'd' 
                                        AND sub1.record_type_code = 'b'
    JOIN  sierra_view.varfield_view sub2 ON b.id = sub2.record_id 
                                        AND sub2.varfield_type_code = 'd' 
                                        AND sub2.record_type_code = 'b'
WHERE sub1.id > sub2.id AND sub1.field_content = sub2.field_content
ORDER BY "Bib Record", "Dupl Subject";
