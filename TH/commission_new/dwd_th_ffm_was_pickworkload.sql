/*=====================================================================+
表名称：  dwd_th_ffm_was_pickworkload
功能描述：泰国 拣货单 明细数据

需求来源：
编写人员: 王昱棋
设计日期：2024/10/22
        修改日期:
        修改人员:
        修改原因:
-----------------------------------------------------------------------
---存在问题：
-----------------------------------------------------------------------
+=====================================================================*/

# drop table if exists dwm.dwd_th_ffm_was_pickworkload;
# create table dwm.dwd_th_ffm_was_pickworkload as
# delete from dwm.dwd_th_ffm_was_pickworkload where dt >='2025-01-01' ; -- 先删除数据
# insert into dwm.dwd_th_ffm_was_pickworkload -- 再插入数据

SELECT
    -- left(oobt.gmt_modified,10) date
    '拣货' title_name
    -- ,oobt.operator user_id
    -- ,mo.job_number
    -- ,si.name
    ,bau.work_no operator
    ,bau.user_name
        ,s.name seller_name
    	,date(oobt.gmt_modified) now_date
        ,sg.name good_name
        ,sg.bar_code
        ,CASE
            when opr_area_code='Pick-FFM-Zone' then '批量单-小件'
            WHEN greatest(LENGTH, width, height)<=250 AND weight <= 10000 AND weight>0 THEN '小件'
            WHEN greatest(LENGTH, width, height)<=500 AND weight <= 10000 AND weight>0 THEN '中件'
            WHEN greatest(LENGTH, width, height)<=1000 AND weight <= 10000 AND weight>0 THEN '大件'
            WHEN (greatest(LENGTH, width, height)>1000 AND weight>0) OR (weight > 10000 and LENGTH>0 and width>0 and height>0 ) THEN '超大件'
            WHEN s.name ='Flash -Thailand' then '其他'
            else '信息不全'
            END TYPEsize
        ,wobo.external_order_code -- DO单号
        ,oobt.order_code
    ,case when  wobo.type in(1)  then actual_num end pickNum -- 2,3是ToB
FROM
    was.oub_out_bound_task oobt
    left join wms_production.seller_goods sg on oobt.item_id = sg.id
    LEFT JOIN was.base_authority_user bau ON oobt.operator = bau.user_id
    LEFT JOIN was.was_out_bound_order wobo  on  wobo.order_code = CONVERT(oobt.order_code using gbk) and oobt.group_id = wobo.group_id
    left join wms_production.member mo on oobt.operator = mo.id
    LEFT JOIN `fle_staging`.`staff_info` si on si.`id` =oobt.operator
    LEFT JOIN wms_production.seller s on oobt.owner_id=s.id
    WHERE 1=1
    and oobt.del_flag = 0 -- 未删除
    AND oobt.status = 1
    AND oobt.group_id = 1180 -- AGV仓
    AND oobt.type in (1,5)
    and ifnull(s.name, 999)<>'FFM-TH' -- 剔除物料
    # and oobt.gmt_modified + interval -1 hour >= date_sub(date_sub(date_format(now(),'%y-%m-%d'),interval extract(day from now())-1 day),interval 1 month)
    and oobt.gmt_modified + interval -1 hour >= '2025-01-01'
    # and oobt.gmt_modified + interval -1 hour <= date_add(curdate() ,interval -day(curdate())+1 day)





-- ------