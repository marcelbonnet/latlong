SELECT COUNT(*) FROM "issues" 
	INNER JOIN "projects" ON "projects"."id" = "issues"."project_id" 
	INNER JOIN "issue_statuses" ON "issue_statuses"."id" = "issues"."status_id" 
WHERE
	(
		projects.status <> 9 AND projects.id IN 
			(
				SELECT em.project_id FROM enabled_modules em 
				WHERE em.name='issue_tracking'
			)
	) AND
	(
		(issues.status_id IN (SELECT id FROM issue_statuses WHERE is_closed='f')) AND
		(issues.priority_id IN ('2')) AND 
		issues.id  IN 
			(
				SELECT issues.id FROM issues 
				LEFT OUTER JOIN custom_values ON custom_values.customized_type='Issue' 
				AND custom_values.customized_id=issues.id 
				AND custom_values.custom_field_id=111 
				WHERE (custom_values.value LIKE '%teste%')
				AND (
						(
							(1=1)
							AND (
									issues.tracker_id IN
										(
											SELECT tracker_id 
											FROM custom_fields_trackers 
											WHERE custom_field_id = 111
										)
								)
							AND (
									EXISTS (
										SELECT 1 FROM custom_fields ifa 
										WHERE ifa.is_for_all = 't' 
										AND ifa.id = 111
									) 
									OR issues.project_id IN (
										SELECT project_id FROM custom_fields_projects 
										WHERE custom_field_id = 111)
								)
						)
					)
			)
		AND issues.id IN ( SELECT issue_id FROM latlongs WHERE (ST_Distance(  ST_GeographyFromText('SRID=4326;POINT(-49.273056 -25.427778)') ,  ST_GeographyFromText('SRID=4326;POINT( -47.929722 -15.779722  )') )) > 1000000 AND projects.id = 27 )
	);




SELECT COUNT(*) FROM "issues" INNER JOIN "projects" ON "projects"."id" = "issues"."project_id" INNER JOIN "issue_statuses" ON "issue_statuses"."id" = "issues"."status_id" WHERE (projects.status <> 9 AND projects.id IN (SELECT em.project_id FROM enabled_modules em WHERE em.name='issue_tracking')) AND ((issues.status_id IN (SELECT id FROM issue_statuses WHERE is_closed='f')));
 count 
-------
  9897
(1 row)



SELECT COUNT(*) FROM "issues" INNER JOIN "projects" ON "projects"."id" = "issues"."project_id" INNER JOIN "issue_statuses" ON "issue_statuses"."id" = "issues"."status_id" WHERE (projects.status <> 9 AND projects.id IN (SELECT em.project_id FROM enabled_modules em WHERE em.name='issue_tracking')) AND ((issues.status_id IN (SELECT id FROM issue_statuses WHERE is_closed='f'))   AND issues.id IN ( 17826 )  AND projects.id = 27) ;


SELECT issue_id FROM latlongs WHERE ( ST_Distance( ponto, ST_GeographyFromText('SRID=4326;POINT( -49.273056 -25.427778 )') ) ) <= 200000;

	SELECT COUNT(*) FROM "issues" INNER JOIN "projects" ON "projects"."id" = "issues"."project_id" INNER JOIN "issue_statuses" ON "issue_statuses"."id" = "issues"."status_id" WHERE (projects.status <> 9 AND projects.id IN (SELECT em.project_id FROM enabled_modules em WHERE em.name='issue_tracking')) AND ((issues.status_id IN (SELECT id FROM issue_statuses WHERE is_closed='f')) AND issues.id IN ( SELECT issue_id FROM latlongs WHERE ( ST_Distance( ponto, ST_GeographyFromText('SRID=4326;POINT( -49.273056 -25.427778 )') ) <= 200000 ) ) AND projects.id = 27);