/*=====================================================================+
        表名称：  dwm.dwd_th_ffm_commission_one
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
# drop table if exists dwm.dwd_th_ffm_commission_one;
# create table dwm.dwd_th_ffm_commission_one as
SELECT
      sr.月份
      ,sr.物理仓
      ,sr.序号 员工序号
      ,sg.序号 部门序号
      ,sr.部门
      ,sr.部门V2
      ,sr.工号
      ,if(sr.物理仓='AGV',agv.Inbound,inbound.工作量) Inbound
      ,if(sr.物理仓='AGV',agv.Pick,picking.工作量) Picking
      ,if(sr.物理仓='AGV',agv.Pack,packing.工作量) Packing
      ,if(sr.物理仓='AGV',agv.Outbound,outbound.工作量) Outbound
      ,if(sr.物理仓='AGV',0,b2b.工作量) B2B
      ,if(sr.物理仓 in ('AGV','BST'),0,pp.工作量) PickingPacking
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
      ,now() + interval -1 hour update_time
FROM
      (
      SELECT
      月份
      ,物理仓
      ,部门
      ,部门V2
      ,工号
      ,分组
      ,KPI
      ,KPI系数
      ,提成系数
      ,备注
      ,序号
      FROM `tmpale`.`tmp_th_ffm_staff_rule1`
      ) sr
LEFT JOIN
      (
      SELECT
      月份
      ,物理仓
      ,部门
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
      ,序号
      FROM `tmpale`.`tmp_th_ffm_staff_goal1`
      ) sg ON sr.月份=sg.月份 AND sr.物理仓=sg.物理仓 AND sr.部门=sg.部门
LEFT JOIN
      (
      SELECT
      left(统计日期,7) 月份
      ,仓库 物理仓
      ,人员信息
      ,职位类别
      ,sum(应出勤) 应出勤
      ,sum(出勤) 出勤
      ,sum(迟到) 迟到
      -- ,sum(请假) 请假
      ,sum(旷工) 旷工
      ,sum(年假) 年假
      ,sum(事假) 事假
      ,sum(病假) 病假
      ,sum(产假) 产假
      ,sum(丧假) 丧假
      ,sum(婚假) 婚假
      ,sum(公司培训假) 公司培训假
      FROM
      (
      SELECT * FROM `dwm`.`dwd_th_ffm_attendance_detail1`
      ) ad
      GROUP BY     仓库
      ,人员信息
      ,部门
      ,职位类别
      ) ad ON sr.月份=ad.月份 -- AND sr.物理仓=ad.物理仓
      AND sr.工号=ad.人员信息
LEFT JOIN
      (
      -- 采购入库；计件(和商品数量相关) 退件仓 包裹销退
      SELECT
      left(收货完成时间, 7) 月份
      ,物理仓
      ,收货人ID
      ,case when 物理仓='BPL-Return' then sum(if(业务类型='包裹销退',修正商品数量,0))
            else sum(if(业务类型='采购入库',修正商品数量,0))
            end 工作量
      FROM dwm.dwd_th_ffm_inbound_detail1
      WHERE 物理仓!='AGV'
      and seller_name not in ('FFM-TH', 'Flash -Thailand')
      GROUP BY left(收货完成时间, 7)
      ,物理仓
      ,收货人ID
      ) inbound ON sr.月份=inbound.月份 AND sr.物理仓=inbound.物理仓 AND sr.工号=inbound.收货人ID
LEFT JOIN
      (
      -- 计件(和商品数量相关) 发货，出库
      SELECT
      left(完成时间, 7) 月份
      ,物理仓
      ,员工ID
      ,sum(修正商品数量) 工作量
      FROM dwm.dwd_th_ffm_picking_detail1
      WHERE 订单状态!=1000
      AND 业务类型 in ('发货','出库')
      AND 物理仓!='AGV'
      AND 虚拟仓!='Fans-B2B'
      GROUP BY left(完成时间, 7)
      ,物理仓
      ,员工ID
      ) picking ON sr.月份=picking.月份 AND sr.物理仓=picking.物理仓 AND sr.工号=picking.员工ID
LEFT JOIN
      (
      -- 计件(和商品数量相关) 发货，出库
      SELECT
      left(出库完成时间, 7) 月份
      ,物理仓
      ,复核人ID
      ,sum(修正商品数量) 工作量
      FROM dwm.dwd_th_ffm_outbound_detail1
      WHERE 订单状态!=1000
      AND 业务类型 in ('发货','出库')
      AND 物理仓!='AGV'
      AND 虚拟仓!='Fans-B2B'
      and seller_name not in ('FFM-TH', 'Flash -Thailand')
      GROUP BY left(出库完成时间, 7)
      ,物理仓
      ,复核人ID
      ) packing ON sr.月份=packing.月份 AND sr.物理仓=packing.物理仓 AND sr.工号=packing.复核人ID
LEFT JOIN
      (
      -- 箱单 发货，出库
      SELECT
      left(出库完成时间, 7) 月份
      ,物理仓
      ,复核人ID
      ,count(distinct 箱单号) 工作量
      FROM dwm.dwd_th_ffm_outbound_detail1
      WHERE 订单状态!=1000
      AND 业务类型 in ('发货','出库')
      AND 物理仓!='AGV'
      AND 虚拟仓!='Fans-B2B'
      and seller_name not in ('FFM-TH', 'Flash -Thailand')
      GROUP BY left(出库完成时间, 7)
      ,物理仓
      ,复核人ID
      ) outbound ON sr.月份=outbound.月份 AND sr.物理仓=outbound.物理仓 AND sr.工号=outbound.复核人ID
LEFT JOIN
      (
      SELECT
      月份
      ,物理仓
      ,工号
      ,`Receive`+`Putaway` Inbound
      ,Pick
      ,Pack
      ,Outbound
      FROM `tmpale`.`tmp_th_ffm_agv_stat1`
      ) agv ON sr.月份=agv.月份 AND sr.物理仓=agv.物理仓 AND sr.工号=agv.工号
LEFT JOIN
      (
      -- 商品数量 发货，出库，调拨出库
      SELECT
      left(完成时间, 7) 月份
      ,物理仓
      ,员工ID
      ,sum(商品数量) 工作量
      FROM dwm.dwd_th_ffm_picking_detail1
      WHERE 订单状态!=1000
      AND 业务类型 in ('发货','出库','调拨出库')
      AND 物理仓!='AGV'
      AND 虚拟仓='Fans-B2B'
      GROUP BY left(完成时间, 7)
      ,物理仓
      ,员工ID
      ) b2b ON sr.月份=b2b.月份 AND sr.物理仓=b2b.物理仓 AND sr.工号=b2b.员工ID
LEFT JOIN
      (
      -- 箱单 发货，出库  LAS BPL-Return
      SELECT
      left(出库完成时间, 7) 月份
      ,物理仓
      ,复核人ID
      ,count(distinct 箱单号) 工作量
      FROM dwm.dwd_th_ffm_outbound_detail1
      WHERE 订单状态!=1000
      AND 业务类型 in ('发货','出库')
      and seller_name not in ('FFM-TH', 'Flash -Thailand')
      AND 物理仓!='AGV'
      AND 虚拟仓!='Fans-B2B'
      GROUP BY left(出库完成时间, 7)
      ,物理仓
      ,复核人ID
      ) pp ON sr.月份=pp.月份 AND sr.物理仓=pp.物理仓 AND sr.工号=pp.复核人ID
LEFT JOIN
      (
      -- 每个月罚款
      SELECT
      月份
      ,工号
      ,sum(罚款总金额) 罚款总金额
      ,sum(if(罚款类别一='业务',罚款总金额,0)) 业务罚款
      ,sum(if(罚款类别一='现场管理',罚款总金额,0)) 现场管理罚款
      ,sum(if(罚款类别一='考勤',罚款总金额,0)) 考勤罚款
      FROM
      (
      SELECT
            fb.`fine_sn` 罚款编号
            ,case fb.`status`
                  when 0 then '初始化'
                  when 1 then '创建'
                  when 2 then '审核'
                  when 3 then '作废'
                  end 状态
            ,mb.`job_number` 工号
            ,mb.`name` 姓名
            ,wh.`name` 所属仓库
            ,wb.`name` 罚款类别一
            ,wbd.`zh` 罚款类别二
            ,fb.`biz_order_sn` 关联单号
            ,fb.`biz_date` 业务发生日期
            ,fb.`amount`*0.01 预罚款金额
            ,fb.`reason` 罚款原因
            ,case fb.`adjust_type`
                  when 0 then '增加'
                  when 1 then '减少'
                  end 调整类型
            ,fb.`adjust_amount` 调整金额
            ,fb.`adjust_reason` 调整原因
            ,(fb.`amount`+fb.`adjust_amount`)*0.01 罚款总金额
            ,fb.`creator_name` 创建人
            ,left(date_add(fb.`created`, interval -60 minute), 7) 月份
            ,date_add(fb.`created`, interval -60 minute) 创建时间
            ,fb.`auditor_id` 审核人
            ,fb.`audited` 审核时间
            ,fb.`remark` 备注
      FROM `wms_production`.`fine_bill` fb
      LEFT JOIN `wms_production`.`wordbook_detail` wbd on wbd.`id`=fb.`type`
      LEFT JOIN `wms_production`.`wordbook` wb on wb.`id`=wbd.`wordbook_id`
      LEFT JOIN `wms_production`.`warehouse` wh on wh.`id`=fb.`warehouse_id`
      LEFT JOIN `wms_production`.`member` mb on mb.`id`=fb.`member_id`
      WHERE fb.`status`!=3
      ) fb
      GROUP BY 月份
      ,工号
      ) fb ON sr.月份=fb.月份 AND sr.工号=fb.工号