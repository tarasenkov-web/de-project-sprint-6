with user_group_messages as (
    select 
            lgd.hk_group_id,
            count(distinct sdi.message_from) as cnt_users_in_group_with_messages
            from STV2025081111__DWH.s_dialog_info sdi
            left join STV2025081111__DWH.l_groups_dialogs lgd on sdi.hk_message_id = lgd.hk_message_id
           group by lgd.hk_group_id
),

user_group_log as (
    select 
    lugs.hk_group_id,
    count(distinct hk_user_id) as cnt_added_users
    from STV2025081111__DWH.l_user_group_activity lugs
    left join STV2025081111__DWH.s_auth_history sah on sah.hk_l_user_group_activity = lugs.hk_l_user_group_activity
    inner join 
    	(select hk_group_id, ROW_NUMBER() OVER (ORDER BY registration_dt) AS row_num_rd from STV2025081111__DWH.h_groups) hg
    ON hg.hk_group_id = lugs.hk_group_id and hg.row_num_rd<10
    where sah.event = 'add'   
    group by lugs.hk_group_id
    
)

select ugl.hk_group_id
		,cnt_users_in_group_with_messages
        ,cnt_added_users
        ,(CASE WHEN cnt_added_users>0 THEN ROUND(cnt_users_in_group_with_messages/cnt_added_users,2) else 0 end) as group_conversion
from user_group_log ugl
left join user_group_messages ugm ON ugl.hk_group_id=ugm.hk_group_id
order by cnt_added_users desc
limit 10
;