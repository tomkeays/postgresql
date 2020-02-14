---
-- this query will get bib information from holds that are INN-Reach or ILL and have items on the holdshelf 
-- ( commented out below to show all holds in this example )
-----

DROP TABLE IF EXISTS temp_holds_data;
CREATE TEMP TABLE temp_holds_data AS
SELECT
p.ptype_code,
p.home_library_code as patron_home_library_code,
n.last_name || ', ' ||n.first_name || COALESCE(' ' || NULLIF(n.middle_name, ''), '') AS "patron_name",
r.record_type_code || r.record_num as record_num,
CASE
	WHEN r.record_type_code = 'i' THEN (
		SELECT
		i.location_code
		
		FROM
		sierra_view.item_record as i

		WHERE
		i.record_id = r.id

		LIMIT 1
	)
	ELSE NULL
END as item_location_code,
CASE
	WHEN r.record_type_code = 'i' THEN (
		SELECT
		i.item_status_code

		FROM
		sierra_view.item_record as i

		WHERE
		i.record_id = r.id

		LIMIT 1
	)
	ELSE NULL
END as item_record_status_code,

CASE
	WHEN r.record_type_code = 'i' THEN (
		SELECT
		v.field_content

		FROM
		sierra_view.varfield as v

		WHERE 
		v.record_id = r.id
		AND v.varfield_type_code = 'b'

		ORDER BY
		v.occ_num

		LIMIT 1
	)
	ELSE NULL
END as item_record_barcode,

-- get the bib record id from holds (which can be item-level, volume-level, or bib-level)
CASE
	WHEN r.record_type_code = 'i' THEN (
		SELECT
		l.bib_record_id

		FROM
		sierra_view.bib_record_item_record_link as l

		WHERE
		l.item_record_id = h.record_id

		LIMIT 1
	)

	WHEN r.record_type_code = 'j' THEN (
		SELECT
		l.bib_record_id

		FROM
		sierra_view.bib_record_volume_record_link as l

		WHERE
		l.volume_record_id = h.record_id

		LIMIT 1
	)

	WHEN r.record_type_code = 'b' THEN (
		h.record_id
	)

	ELSE NULL
END as bib_record_id,

CASE
	WHEN h.status = '0' THEN 'On hold'
	WHEN h.status = 'b' THEN 'Bib hold ready for pickup.'
	WHEN h.status = 'j' THEN 'Volume hold ready for pickup.'
	WHEN h.status = 'i' THEN 'Item hold ready for pickup.'
	WHEN h.status = 't' THEN 'Bib, item, or volume in transit to pickup location.'
END as hold_status,

h.*

FROM
sierra_view.hold as h

LEFT OUTER JOIN
sierra_view.record_metadata as r
ON
  r.id = h.record_id

LEFT OUTER JOIN
sierra_view.patron_record as p
ON
  p.record_id = h.patron_record_id

LEFT OUTER JOIN
sierra_view.patron_record_fullname as n
ON
  n.patron_record_id = h.patron_record_id

-- uncomment / comment out here to see all items on hold shelf or limit to
-- INN-Reach / ILL holds 
-- WHERE
-- (	is_ir IS true
-- 	OR is_ill IS true
-- )
;
-----


CREATE INDEX index_patron_name ON temp_holds_data (patron_name);
CREATE INDEX index_pickup_location_code ON temp_holds_data (pickup_location_code);
CREATE INDEX index_item_location_code ON temp_holds_data (item_location_code);
CREATE INDEX index_item_record_status_code ON temp_holds_data (item_record_status_code);


-----
SELECT
t.pickup_location_code,
CASE
	WHEN t.item_record_status_code = '-' THEN 'AVAILABLE'
	WHEN t.item_record_status_code = 'm' THEN 'MISSING'
	WHEN t.item_record_status_code = 'z' THEN 'CL RETURNED'
	WHEN t.item_record_status_code = 'o' THEN 'LIB USE ONLY'
	WHEN t.item_record_status_code = 'n' THEN 'BILLED NOTPAID'
	WHEN t.item_record_status_code = '$' THEN 'BILLED PAID'
	WHEN t.item_record_status_code = 't' THEN 'IN TRANSIT'
	WHEN t.item_record_status_code = '!' THEN 'ON HOLDSHELF'
	WHEN t.item_record_status_code = 'l' THEN 'LOST'
	-- At INN-Reach sites, the following additional codes and definitions are standard:
	WHEN t.item_record_status_code = '@' THEN 'OFF SITE'
	WHEN t.item_record_status_code = '#' THEN 'RECEIVED'
	WHEN t.item_record_status_code = '%' THEN 'RETURNED'
	WHEN t.item_record_status_code = '&' THEN 'REQUEST'
	WHEN t.item_record_status_code = '_' THEN 'REREQUEST'
	WHEN t.item_record_status_code = '(' THEN 'PAGED'
	WHEN t.item_record_status_code = ')' THEN 'CANCELLED'
	WHEN t.item_record_status_code = '1' THEN 'LOAN REQUESTED'
	ELSE t.item_record_status_code
END as item_record_status,
t.patron_name,
t.hold_status,
t.item_location_code,
p.best_title,
p.publish_year,
-- we can pick and choose what other stuff to select from here
t.*

FROM 
temp_holds_data as t

JOIN
sierra_view.bib_record_property as p
ON
  p.bib_record_id = t.bib_record_id

WHERE
-- to show only itmes that are listed as being on the holdshelf
t.item_record_status_code = '&'

ORDER BY
t.pickup_location_code,
t.item_record_status_code,
t.patron_name,
t.hold_status,
t.item_location_code