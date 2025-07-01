/*=====================================================================+
        表名称：  dwm.dwd_th_ffm_commission_five
        功能描述：
        需求来源：
        编写人员:
        设计日期：
        修改日期:
        修改人员:
        修改原因:
      -----------------------------------------------------------------------
      ---存在问题：
      -----------------------------------------------------------------------
      +=====================================================================*/
# drop table if exists dwm.dwd_th_ffm_commission_five ;
# create table dwm.dwd_th_ffm_commission_five  as
SELECT
    月份
    ,物理仓
    ,员工序号
    ,部门序号
    ,工号
    ,Inbound
    ,Picking
    ,Packing
    ,Outbound
    ,B2B
    ,PickingPacking
    ,分组
    ,部门
    ,出勤
    ,基础提成
    ,提成
    ,业务罚款
    ,现场管理罚款
    ,考勤罚款
    ,全勤奖
    ,奖励
    ,if(物理仓='AGV',case
    #when	1=1 then  奖惩提成 addby 王昱棋 20240412 道麟哥的修改建议
        when 旷工 < 1 then 奖惩提成
        # when 事病假>3 then 0
        # else 奖惩提成
        end,case when 旷工>0 then 0
        when 请假>3 then 0
        when 应出勤<=0 then 0
        when 请假>2 and 请假<=3 then 奖惩提成/应出勤*出勤*0.6
        when 请假>1 and 请假<=2 then 奖惩提成/应出勤*出勤*0.75
        when 请假<=1 then 奖惩提成/应出勤*出勤
        end
        ) 应发提成
    ,迟到
    ,旷工
    ,年假
    ,事假
    ,病假
    ,产假
    ,丧假
    ,婚假
    ,公司培训假
    ,应出勤
    ,提成系数
    ,超额提成目标
    ,超额提成工作量
    ,超额系数
    ,请假
    ,事病假
    ,case when 物理仓='AGV' then Inbound+Picking+Packing+Outbound
        when 物理仓 in ('LAS','BPL-Return') then if(超额系数!=0,基础提成/超额系数,0)
        when 物理仓='BST' AND 部门 in ('Inbound','Outbound','B2B') then if(超额系数!=0,基础提成/超额系数,0)
        when 物理仓='BST' AND 部门 in ('Put away','Picking') then Picking
        when 物理仓='BST' AND 部门 in ('Packing') then Packing
        else 0
        end 计提工作量
    ,now() + interval -1 hour update_time
FROM
    (
    SELECT
        月份
        ,物理仓
        ,员工序号
        ,部门序号
        ,工号
        ,Inbound
        ,Picking
        ,Packing
        ,Outbound
        ,B2B
        ,PickingPacking
        ,分组
        ,部门
        ,出勤
        ,基础提成
        ,提成
        ,业务罚款
        ,现场管理罚款
        ,考勤罚款
        ,全勤奖
        ,奖励
        ,if(提成-IFNULL(业务罚款,0) -IFNULL(现场管理罚款,0) -IFNULL(考勤罚款,0) +全勤奖+奖励>0,提成-IFNULL(业务罚款,0) -IFNULL(现场管理罚款,0) -IFNULL(考勤罚款,0) +全勤奖+奖励,0) 奖惩提成
        ,应发提成
        ,迟到
        ,旷工
        ,年假
        ,事假
        ,病假
        ,产假
        ,丧假
        ,婚假
        ,公司培训假
        ,应出勤
        ,提成系数
        ,超额提成目标
        ,超额提成工作量
        ,超额系数
        ,请假
        ,事病假
    FROM
        (
        SELECT
            sr.月份
            ,sr.物理仓
            ,员工序号
            ,部门序号
            ,工号
            ,Inbound
            ,Picking
            ,Packing
            ,Outbound
            ,B2B
            ,PickingPacking
            ,分组
            ,部门
            ,出勤
            ,case when sr.物理仓='BPL-Return' AND 部门='Supervisor' then sv.应发提成
                when sr.物理仓='LAS' AND 部门='Supervisor' then sv.应发提成*提成系数
                when sr.物理仓='BST' AND 部门='Supervisor' AND 工号='56699' then bsti.应发提成
                when sr.物理仓='BST' AND 部门='Supervisor' AND 工号='53539' then bstp.应发提成
                when sr.物理仓='BST' AND 部门='Supervisor' AND 工号='75655' then bstp.应发提成
                else sr.基础提成
                end 基础提成
            ,case when sr.物理仓='BPL-Return' AND 部门='Supervisor' then sv.应发提成
                when sr.物理仓='LAS' AND 部门='Supervisor' then sv.应发提成*提成系数
                when sr.物理仓='BST' AND 部门='Supervisor' AND 工号='56699' then bsti.应发提成
                when sr.物理仓='BST' AND 部门='Supervisor' AND 工号='53539' then bstp.应发提成
                when sr.物理仓='BST' AND 部门='Supervisor' AND 工号='75655' then bstp.应发提成
                else sr.提成
                end 提成
            ,业务罚款
            ,现场管理罚款
            ,考勤罚款
            ,全勤奖
            ,奖励
            ,sr.应发提成
            ,迟到
            ,旷工
            ,年假
            ,事假
            ,病假
            ,产假
            ,丧假
            ,婚假
            ,公司培训假
            ,应出勤
            ,提成系数
            ,超额提成目标
            ,超额提成工作量
            ,超额系数
            ,请假
            ,事病假
        FROM
            (
            SELECT
                月份
                ,物理仓
                ,员工序号
                ,部门序号
                ,工号
                ,Inbound
                ,Picking
                ,Packing
                ,Outbound
                ,B2B
                ,PickingPacking
                ,分组
                ,部门
                ,出勤
                ,基础提成
                ,提成
                ,业务罚款
                ,现场管理罚款
                ,考勤罚款
                ,全勤奖
                ,奖励
                ,应发提成
                ,迟到
                ,旷工
                ,年假
                ,事假
                ,病假
                ,产假
                ,丧假
                ,婚假
                ,公司培训假
                ,应出勤
                ,提成系数
                ,超额提成目标
                ,超额提成工作量
                ,超额系数
                ,请假
                ,事病假
            FROM dwm.dwd_th_ffm_commission_four
            ) sr
        LEFT JOIN
            (
            SELECT
                月份
                ,物理仓
                ,avg(应发提成) 应发提成
            FROM dwm.dwd_th_ffm_commission_four
            WHERE 物理仓 in ('LAS','BPL-Return')
                AND 部门!='Supervisor'
            GROUP BY         月份
                ,物理仓
            ) sv on sr.月份=sv.月份 and sr.物理仓=sv.物理仓
        LEFT JOIN
            (
            SELECT
                月份
                ,物理仓
                ,avg(应发提成) 应发提成
            FROM dwm.dwd_th_ffm_commission_four
            WHERE 物理仓 in ('BST')
                AND 部门='Inbound'
            GROUP BY 月份
                ,物理仓
            ) bsti on sr.月份=bsti.月份 and sr.物理仓=bsti.物理仓
        LEFT JOIN
            (
            SELECT
                月份
                ,物理仓
                ,avg(应发提成) 应发提成
            FROM dwm.dwd_th_ffm_commission_four
            WHERE 物理仓 in ('BST')
                AND 部门 in ('Picking','Packing')
            GROUP BY 月份
                ,物理仓
            ) bstp on sr.月份=bstp.月份 and sr.物理仓=bstp.物理仓
        LEFT JOIN
            (
            SELECT
                月份
                ,物理仓
                ,avg(应发提成) 应发提成
            FROM dwm.dwd_th_ffm_commission_four
            WHERE 物理仓 in ('BST')
                AND 部门 in ('Packing','Outbound')
            GROUP BY 月份
                ,物理仓
            ) bsto on sr.月份=bsto.月份 and sr.物理仓=bsto.物理仓
        -- WHERE sr.物理仓 in ('LAS','BPL-Return','BST','AGV')
        --         AND 部门='Supervisor'
        ) sr
    ) sr