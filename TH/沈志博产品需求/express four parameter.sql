-- ID_express four parameter
select
    a.seller_id
     ,b.name
     ,b.`disabled`
     ,b.`is_cooperation`
     ,a.express_pay_detail
from
    wms_production.seller_balance a
join wms_production.seller b on a.`seller_id`  = b.`id`
where a.express_pay_detail != ''
  and a.express_pay_detail != 'all'