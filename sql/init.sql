DELETE FROM tenant WHERE id > 100;
DELETE FROM visit_history WHERE created_at >= '1654041600';
UPDATE id_generator SET id=2678400000 WHERE stub='a';
ALTER TABLE id_generator AUTO_INCREMENT=2678400000;

# create index if not exists visit_history_tenant_id_c_id_player_id_created_at_index
#     on visit_history (tenant_id, competition_id, player_id,created_at);