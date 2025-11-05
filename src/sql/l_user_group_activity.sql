create table STV2025081111__DWH.l_user_group_activity
(
hk_l_user_group_activity int primary key,
hk_user_id int not null CONSTRAINT fk_l_user_group_activity_user REFERENCES STV2025081111__DWH.h_users (hk_user_id),
hk_group_id int not null CONSTRAINT fk_l_user_group_activity_groups REFERENCES STV2025081111__DWH.h_groups (hk_group_id),
load_dt datetime,
load_src varchar(20)
)

order by load_dt
SEGMENTED BY hk_l_user_group_activity all nodes
PARTITION BY load_dt::date
GROUP BY calendar_hierarchy_day(load_dt::date, 3, 2); 


INSERT INTO STV2025081111__DWH.l_user_group_activity(hk_l_user_group_activity, hk_user_id,hk_group_id,load_dt,load_src)
select distinct
hash(hu.hk_user_id,hg.hk_group_id),
hu.hk_user_id,
hg.hk_group_id,
now() as load_dt,
's3' as load_src
from STV2025081111__STAGING.group_log as gl
left join STV2025081111__DWH.h_users as hu on gl.user_id = hu.user_id
left join STV2025081111__DWH.h_groups as hg on gl.group_id = hg.group_id
where hash(hu.hk_user_id,hg.hk_group_id) not in (select hk_l_user_group_activity from STV2025081111__DWH.l_user_group_activity);