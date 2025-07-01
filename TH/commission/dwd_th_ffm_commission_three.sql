/*=====================================================================+
        表名称：  dwm.dwd_th_ffm_commission_three
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
# drop table if exists dwm.dwd_th_ffm_commission_three;
# create table dwm.dwd_th_ffm_commission_three as
SELECT
    月份
    ,物理仓
    ,员工序号
    ,部门序号
    ,部门
    ,工号
    ,Inbound
    ,Picking
    ,Packing
    ,Outbound
    ,B2B
    ,PickingPacking
    ,应出勤
    ,出勤
    ,迟到
    ,旷工
    ,年假
    ,事假
    ,病假
    ,产假
    ,丧假
    ,婚假
    ,公司培训假
    ,分组
    ,KPI
    ,KPI系数
    ,提成系数
    ,超额提成
    ,阶梯提成
    ,支援提成
    ,KPI提成
    ,平均提成
    ,KPI奖金
    ,目标值
    ,超额系数
    ,入库超额系数
    ,拣货超额系数
    ,打包超额系数
    ,出库超额系数
    ,入库支援系数
    ,拣货支援系数
    ,打包支援系数
    ,出库支援系数
    ,业务罚款
    ,现场管理罚款
    ,考勤罚款
    ,全勤天数
    ,仓库总出勤
    ,仓库人数
    ,仓库入库
    ,仓库拣货
    ,仓库打包
    ,仓库出库
    ,仓库B2B
    ,仓库拣货打包
    ,部门人数
    ,部门总出勤
    ,部门入库
    ,部门拣货
    ,部门打包
    ,部门出库
    ,部门B2B
    ,部门拣货打包
    ,分组人数
    ,分组打包
    ,超额提成目标
    ,超额提成工作量
    ,人均工作量提成金额
    ,超额提成金额
    ,支援提成金额
    ,KPI提成金额
    ,阶梯提成金额
    ,now() + interval -1 hour update_time
    -- ,if(超额提成金额+支援提成金额+KPI提成金额>0,超额提成金额+支援提成金额+KPI提成金额,0)*提成系数 基础提成金额
FROM
    (
    SELECT
        月份
        ,物理仓
        ,员工序号
        ,部门序号
        ,部门
        ,工号
        ,Inbound
        ,Picking
        ,Packing
        ,Outbound
        ,B2B
        ,PickingPacking
        ,应出勤
        ,出勤
        ,迟到
        ,旷工
        ,年假
        ,事假
        ,病假
        ,产假
        ,丧假
        ,婚假
        ,公司培训假
        ,分组
        ,KPI
        ,KPI系数
        ,提成系数
        ,超额提成
        ,阶梯提成
        ,支援提成
        ,KPI提成
        ,平均提成
        ,KPI奖金
        ,目标值
        ,超额系数
        ,入库超额系数
        ,拣货超额系数
        ,打包超额系数
        ,出库超额系数
        ,入库支援系数
        ,拣货支援系数
        ,打包支援系数
        ,出库支援系数
        ,业务罚款
        ,现场管理罚款
        ,考勤罚款
        ,全勤天数
        ,仓库总出勤
        ,仓库人数
        ,仓库入库
        ,仓库拣货
        ,仓库打包
        ,仓库出库
        ,仓库B2B
        ,仓库拣货打包
        ,部门人数
        ,部门总出勤
        ,部门入库
        ,部门拣货
        ,部门打包
        ,部门出库
        ,部门B2B
        ,部门拣货打包
        ,分组人数
        ,分组打包
        ,超额提成目标
        ,超额提成工作量
        ,超额提成工作量*超额系数/部门人数 人均工作量提成金额
        ,case when 物理仓='AGV' and 部门='Inbound' and 超额提成工作量>0 then 超额提成工作量*入库超额系数
            when 物理仓='AGV' and 部门='Inbound' and 超额提成工作量<=0 then 超额提成工作量*入库支援系数
            when 物理仓='AGV' and 部门='Picking' and 超额提成工作量>0 then 超额提成工作量*拣货超额系数
            when 物理仓='AGV' and 部门='Picking' and 超额提成工作量<=0 then 超额提成工作量*拣货支援系数
            when 物理仓='AGV' and 部门='Packing' and 超额提成工作量>0  then 超额提成工作量*打包超额系数
            when 物理仓='AGV' and 部门='Packing' and 超额提成工作量<=0  then 超额提成工作量*打包支援系数
            when 物理仓='AGV' and 部门='Outbound' and 超额提成工作量>0  then 超额提成工作量*出库超额系数
            when 物理仓='AGV' and 部门='Outbound' and 超额提成工作量<=0  then 超额提成工作量*出库支援系数
            -- else if(超额提成工作量-超额提成目标>0,(超额提成工作量-超额提成目标)*超额系数,0) / 部门人数
            else 0
            end 超额提成金额
        ,case when 物理仓='AGV' and 部门='Inbound' and 超额提成工作量>0 then Picking*拣货超额系数+Packing*打包超额系数+Outbound*出库超额系数
            when 物理仓='AGV' and 部门='Inbound' and 超额提成工作量<=0 then  Picking*拣货支援系数+Packing*打包支援系数+Outbound*出库支援系数
            when 物理仓='AGV' and 部门='Picking' and 超额提成工作量>0 then Inbound*入库超额系数+Packing*打包超额系数+Outbound*出库超额系数
            when 物理仓='AGV' and 部门='Picking' and 超额提成工作量<=0 then Inbound*入库支援系数/2+Packing*打包支援系数+Outbound*出库支援系数
            when 物理仓='AGV' and 部门='Packing' and 超额提成工作量>0  then Inbound*入库超额系数+Picking*拣货超额系数+Outbound*出库超额系数
            when 物理仓='AGV' and 部门='Packing' and 超额提成工作量<=0  then Inbound*入库支援系数/2+Picking*拣货支援系数+Outbound*出库支援系数
            when 物理仓='AGV' and 部门='Outbound' and 超额提成工作量>0  then Inbound*入库超额系数+Picking*拣货超额系数+Packing*打包超额系数
            when 物理仓='AGV' and 部门='Outbound' and 超额提成工作量<=0  then Inbound*入库支援系数/2+Picking*拣货支援系数+Packing*打包支援系数
            when 物理仓='AGV' and 部门 in ('CS','QAQC','Admin','AGV maintance') and KPI>=3 then Inbound*入库超额系数/2+Picking*拣货超额系数+Packing*打包超额系数+Outbound*出库超额系数
            when 物理仓='AGV' and 部门 in ('Inventory') and KPI>='0.75' then Inbound*入库超额系数/2+Picking*拣货超额系数+Packing*打包超额系数+Outbound*出库超额系数
            else 0
            end 支援提成金额
        ,KPI奖金*KPI系数 KPI提成金额
        ,阶梯提成工作量
        ,case when 物理仓='BST' and 部门='Picking' and 阶梯提成工作量-40000>0 then 7000
            when 物理仓='BST' and 部门='Picking' and 阶梯提成工作量-35000>0 then 5800
            when 物理仓='BST' and 部门='Picking' and 阶梯提成工作量-32000>0 then 5000
            when 物理仓='BST' and 部门='Picking' and 阶梯提成工作量-28000>0 then 4300
            when 物理仓='BST' and 部门='Picking' and 阶梯提成工作量-25000>0 then 3600
            when 物理仓='BST' and 部门='Picking' and 阶梯提成工作量-22000>0 then 3000
            when 物理仓='BST' and 部门='Picking' and 阶梯提成工作量-19000>0 then 2400
            when 物理仓='BST' and 部门='Picking' and 阶梯提成工作量-16000>0 then 1800
            when 物理仓='BST' and 部门='Picking' and 阶梯提成工作量-13000>0 then 1200
            when 物理仓='BST' and 部门='Picking' and 阶梯提成工作量-10000>0 then 500
            when 物理仓='BST' and 部门='Packing' and 阶梯提成工作量-38000>0 then 13200/分组人数
            when 物理仓='BST' and 部门='Packing' and 阶梯提成工作量-33000>0 then 11100/分组人数
            when 物理仓='BST' and 部门='Packing' and 阶梯提成工作量-31000>0 then 9600/分组人数
            when 物理仓='BST' and 部门='Packing' and 阶梯提成工作量-29000>0 then 8400/分组人数
            when 物理仓='BST' and 部门='Packing' and 阶梯提成工作量-27000>0 then 7200/分组人数
            when 物理仓='BST' and 部门='Packing' and 阶梯提成工作量-25000>0 then 6120/分组人数
            when 物理仓='BST' and 部门='Packing' and 阶梯提成工作量-23000>0 then 5100/分组人数
            when 物理仓='BST' and 部门='Packing' and 阶梯提成工作量-21000>0 then 4200/分组人数
            when 物理仓='BST' and 部门='Packing' and 阶梯提成工作量-19000>0 then 3210/分组人数
            when 物理仓='BST' and 部门='Packing' and 阶梯提成工作量-17000>0 then 2310/分组人数
            when 物理仓='BST' and 部门='Packing' and 阶梯提成工作量-15000>0 then 1410/分组人数
            when 物理仓='BST' and 部门='Packing' and 阶梯提成工作量-13000>0 then 600/分组人数
            else 0
            end 阶梯提成金额
    FROM
        (
        SELECT
            月份
            ,物理仓
            ,员工序号
            ,部门序号
            ,部门
            ,工号
            ,Inbound
            ,Picking
            ,Packing
            ,Outbound
            ,B2B
            ,PickingPacking
            ,应出勤
            ,出勤
            ,迟到
            ,旷工
            ,年假
            ,事假
            ,病假
            ,产假
            ,丧假
            ,婚假
            ,公司培训假
            ,分组
            ,KPI
            ,KPI系数
            ,提成系数
            ,超额提成
            ,阶梯提成
            ,支援提成
            ,KPI提成
            ,平均提成
            ,KPI奖金
            ,目标值
            ,超额系数
            ,入库超额系数
            ,拣货超额系数
            ,打包超额系数
            ,出库超额系数
            ,入库支援系数
            ,拣货支援系数
            ,打包支援系数
            ,出库支援系数
            ,业务罚款
            ,现场管理罚款
            ,考勤罚款
            ,全勤天数
            ,仓库总出勤
            ,仓库人数
            ,仓库入库
            ,仓库拣货
            ,仓库打包
            ,仓库出库
            ,仓库B2B
            ,仓库拣货打包
            ,部门人数
            ,部门总出勤
            ,部门入库
            ,部门拣货
            ,部门打包
            ,部门出库
            ,部门B2B
            ,部门拣货打包
            ,分组人数
            ,分组打包
            ,超额提成目标
            ,超额提成工作量-超额提成目标 超额提成工作量
            ,阶梯提成工作量
        FROM
            (
            SELECT
                月份
                ,物理仓
                ,员工序号
                ,部门序号
                ,部门
                ,工号
                ,Inbound
                ,Picking
                ,Packing
                ,Outbound
                ,B2B
                ,PickingPacking
                ,应出勤
                ,出勤
                ,迟到
                ,旷工
                ,年假
                ,事假
                ,病假
                ,产假
                ,丧假
                ,婚假
                ,公司培训假
                ,分组
                ,KPI
                ,KPI系数
                ,提成系数
                ,超额提成
                ,阶梯提成
                ,支援提成
                ,KPI提成
                ,平均提成
                ,KPI奖金
                ,目标值
                ,超额系数
                ,入库超额系数
                ,拣货超额系数
                ,打包超额系数
                ,出库超额系数
                ,入库支援系数
                ,拣货支援系数
                ,打包支援系数
                ,出库支援系数
                ,业务罚款
                ,现场管理罚款
                ,考勤罚款
                ,全勤天数
                ,仓库总出勤
                ,仓库人数
                ,仓库入库
                ,仓库拣货
                ,仓库打包
                ,仓库出库
                ,仓库B2B
                ,仓库拣货打包
                ,部门人数
                ,部门总出勤
                ,部门入库
                ,部门拣货
                ,部门打包
                ,部门出库
                ,部门B2B
                ,部门拣货打包
                ,分组人数
                ,分组打包
                ,case when 物理仓='AGV' and 部门='Inbound' then 目标值
                    when 物理仓='AGV' and 部门='Picking' then 目标值
                    when 物理仓='AGV' and 部门='Packing' then 目标值
                    when 物理仓='AGV' and 部门='Outbound' then 目标值
                    when 物理仓='LAS' and 部门='Inbound' then (目标值/全勤天数)*部门总出勤
                    when 物理仓='LAS' and 部门='PickingPacking' then (目标值/全勤天数)*部门总出勤
                    when 物理仓='LAS' and 部门='Outbound' then (目标值/全勤天数)*部门总出勤
                    when 物理仓='BPL-Return' and 部门='Inbound' then 目标值*部门人数
                    when 物理仓='BPL-Return' and 部门='PickingPacking' then 目标值*部门人数
                    when 物理仓='BST' and 部门='Inbound' then (目标值/全勤天数)*部门总出勤
                    when 物理仓='BST' and 部门='Outbound' then (目标值/全勤天数)*部门总出勤
                    when 物理仓='BST' and 部门='B2B' then (目标值/全勤天数)*部门总出勤
                    else 0
                    end 超额提成目标
                ,case when 物理仓='AGV' and 部门='Inbound' then Inbound
                    when 物理仓='AGV' and 部门='Picking' then Picking
                    when 物理仓='AGV' and 部门='Packing' then Packing
                    when 物理仓='AGV' and 部门='Outbound' then Outbound
                    when 物理仓='LAS' and 部门='Inbound' then 仓库入库
                    when 物理仓='LAS' and 部门='PickingPacking' then 仓库拣货打包
                    when 物理仓='LAS' and 部门='Outbound' then 仓库出库
                    when 物理仓='BPL-Return' and 部门='Inbound' then 部门入库
                    when 物理仓='BPL-Return' and 部门='PickingPacking' then 部门拣货打包*2
                    when 物理仓='BST' and 部门='Inbound' then 仓库入库
                    when 物理仓='BST' and 部门='Outbound' then 仓库出库
                    when 物理仓='BST' and 部门='B2B' then 部门B2B
                    else 0
                    end 超额提成工作量
                ,case when 物理仓='BST' and 部门='Picking' then Picking   # *0.8 addby 王昱棋 20231207 把 0.8 的系数去掉, 文桩老师反馈,去掉该参数
                    when 物理仓='BST' and 部门='Packing' then 分组打包 # *0.8 addby 王昱棋 20231118 把 0.8 的系数去掉
                    else 0
                    end 阶梯提成工作量
            FROM
                (
                SELECT
                    sr.月份
                    ,sr.物理仓
                    ,员工序号
                    ,部门序号
                    ,sr.部门
                    ,sr.工号
                    ,Inbound
                    ,Picking
                    ,Packing
                    ,Outbound
                    ,B2B
                    ,PickingPacking
                    ,应出勤
                    ,出勤
                    ,迟到
                    ,旷工
                    ,年假
                    ,事假
                    ,病假
                    ,产假
                    ,丧假
                    ,婚假
                    ,公司培训假
                    ,sr.分组
                    ,KPI
                    ,KPI系数
                    ,提成系数
                    ,超额提成
                    ,阶梯提成
                    ,支援提成
                    ,KPI提成
                    ,平均提成
                    ,KPI奖金
                    ,目标值
                    ,超额系数
                    ,入库超额系数
                    ,拣货超额系数
                    ,打包超额系数
                    ,出库超额系数
                    ,入库支援系数
                    ,拣货支援系数
                    ,打包支援系数
                    ,出库支援系数
                    ,业务罚款
                    ,现场管理罚款
                    ,考勤罚款
                    ,全勤天数
                    ,仓库总出勤
                    ,仓库人数
                    ,仓库入库
                    ,仓库拣货
                    ,仓库打包
                    ,仓库出库
                    ,仓库B2B
                    ,仓库拣货打包
                    ,部门人数
                    ,部门总出勤
                    ,部门入库
                    ,部门拣货
                    ,部门打包
                    ,部门出库
                    ,部门B2B
                    ,部门拣货打包
                    ,分组人数
                    ,分组打包
                FROM
                    (
                    SELECT
                        月份
                        ,物理仓
                        ,员工序号
                        ,部门序号
                        ,部门
                        ,工号
                        ,Inbound
                        ,Picking
                        ,Packing
                        ,Outbound
                        ,B2B
                        ,PickingPacking
                        ,应出勤
                        ,出勤
                        ,迟到
                        ,旷工
                        ,年假
                        ,事假
                        ,病假
                        ,产假
                        ,丧假
                        ,婚假
                        ,公司培训假
                        ,分组
                        ,KPI
                        ,KPI系数
                        ,提成系数
                        ,超额提成
                        ,阶梯提成
                        ,支援提成
                        ,KPI提成
                        ,平均提成
                        ,KPI奖金
                        ,目标值
                        ,超额系数
                        ,入库超额系数
                        ,拣货超额系数
                        ,打包超额系数
                        ,出库超额系数
                        ,入库支援系数
                        ,拣货支援系数
                        ,打包支援系数
                        ,出库支援系数
                        ,业务罚款
                        ,现场管理罚款
                        ,考勤罚款
                    FROM  dwm.dwd_th_ffm_commission_two
                    )  sr
                LEFT JOIN
                    (
                    SELECT
                        月份
                        ,物理仓
                        ,count(distinct if(部门!='Supervisor',工号,null)) 仓库人数
                        ,max(应出勤) 全勤天数
                        ,sum(应出勤) 仓库总出勤
                        ,sum(Inbound) 仓库入库
                        ,sum(Picking) 仓库拣货
                        ,sum(Packing) 仓库打包
                        ,sum(Outbound) 仓库出库
                        ,sum(B2B) 仓库B2B
                        ,sum(PickingPacking) 仓库拣货打包
                    FROM  dwm.dwd_th_ffm_commission_two
                    GROUP BY 月份
                        ,物理仓
                    ) sw ON sr.月份=sw.月份 AND sr.物理仓=sw.物理仓
                LEFT JOIN
                    (
                    SELECT
                        月份
                        ,物理仓
                        ,部门
                        ,count(distinct 工号) 部门人数
                        ,sum(应出勤) 部门总出勤
                        ,sum(Inbound) 部门入库
                        ,sum(Picking) 部门拣货
                        ,sum(Packing) 部门打包
                        ,sum(Outbound) 部门出库
                        ,sum(B2B) 部门B2B
                        ,sum(PickingPacking) 部门拣货打包
                    FROM  dwm.dwd_th_ffm_commission_two
                    GROUP BY 月份
                        ,物理仓
                        ,部门
                    ) swd ON sr.月份=swd.月份 AND sr.物理仓=swd.物理仓 AND sr.部门=swd.部门
                LEFT JOIN
                    (
                    SELECT
                        月份
                        ,物理仓
                        ,分组
                        ,count(0) 分组人数
                        ,sum(Packing) 分组打包
                    FROM  dwm.dwd_th_ffm_commission_two
                    GROUP BY 月份
                        ,物理仓
                        ,分组
                    ) swg ON sr.月份=swg.月份 AND sr.物理仓=swg.物理仓 AND sr.分组=swg.分组
                ) sr
            ) sr
        -- WHERE (物理仓='BST' and 部门 in ('Picking','Packing'))
            -- AND  (部门 in ('Inventory') or 工号 IN (
            --     '625853'
            --     ,'624236'
            --     ,'605978'
            --     ,'602720'
            --     ,'642257'
            --     ,'642414'
            -- ))
        ) sr
    ) sr