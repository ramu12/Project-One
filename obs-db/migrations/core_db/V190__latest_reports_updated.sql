 SET @offId=(SELECT id FROM stretchy_parameter where parameter_label='Office');

insert ignore into stretchy_report values(null ,'Customer Outstanding Report', 'Table', '', 'Client', 'select custinv.client_id as Customer_id,custinv.Name,custinv.office_id,custinv.office,custinv.invoice_date,custinv.Total_invoice,adjust.debitadjust,adjust.creditadjust,ifnull(cast(round(sum(pay.amount_paid),2)as char) ,0)as Total_Collection,cast(round(custinv.Total_invoice - ifnull(sum(pay.amount_paid),0) + ifnull(adjust.debitadjust,0) - ifnull(adjust.creditadjust,0))as char) as Balance from (select  cust.account_no as Customer_Id,cust.display_name as Name,cust.id as client_id,off.id as office_id,off.name as  Office,inv.invoice_date,cast(round(sum(inv.invoice_amount),2)as char)  as Total_invoice  from m_client cust,m_office off,b_invoice inv  where cust.office_id=off.id and cust.id=inv.client_id group by cust.id Order by cust.id ) custinv  left outer join b_payments pay on custinv.client_id=pay.client_id left outer join (SELECT ADJ.CLIENT_ID,sum(ADJ.DBADJ) as debitadjust,sum(ADJ.CRADJ) as creditadjust FROM (SELECT client_id,adjustment_type, SUM((CASE adjustment_type WHEN ''DEBIT'' THEN adjustment_amount ELSE 0 END )) AS DBADJ, SUM((CASE adjustment_type
WHEN ''CREDIT'' THEN adjustment_amount ELSE 0 END )) AS CRADJ FROM b_adjustments GROUP BY client_id,adjustment_type) AS ADJ GROUP BY ADJ.CLIENT_ID) adjust on custinv.client_id=adjust.client_id   where (`office_id` = ''${officeId}'' or -1 = ''${officeId}'')  group by custinv.client_id order by custinv.client_id', 'Customer Outstanding Report', '0', '1');

SET @id = (select id from stretchy_report where report_name='Customer Outstanding Report');
insert ignore into stretchy_report_parameter(report_id,parameter_id,report_parameter_name)values (@id,@offId,'Office');

insert ignore into stretchy_report values(null, 'Plan wise services', 'Table', '', 'Orders', 'select plan.plan_id,plan.plan_description,plan.service_code,plan.plan_status,plan.charge_code,plan.charge_type,plan.active_since,plan.price  from (SELECT  plnmstr.id as plan_id,plnmstr.plan_description,plnprc.service_code,plnmstr.plan_status,plnprc.charge_code,chrgcds.charge_type,concat(chrgcds.charge_duration ,'' '', chrgcds.duration_type) as Active_Since,plnprc.price 
        FROM b_plan_master plnmstr   join b_plan_pricing plnprc on  plnmstr.id=plnprc.plan_id join b_charge_codes chrgcds on plnprc.charge_code=chrgcds.charge_code where plnprc.is_deleted=''n'' and plnmstr.is_deleted=''n'' union all SELECT  plndtl.plan_id,plnmstr.plan_description,plndtl.service_code,plnmstr.plan_status,plnprc.charge_code,chrgcds.charge_type,concat(chrgcds.charge_duration ,'' '', chrgcds.duration_type) as Active_Since,plnprc.price FROM  b_plan_master plnmstr  join  b_plan_detail plndtl on plnmstr.id=plndtl.plan_id join b_plan_pricing plnprc on  plndtl.plan_id=plnprc.plan_id and  plndtl.service_code=plnprc.service_code join b_charge_codes chrgcds on plnprc.charge_code=chrgcds.charge_code where plndtl.is_deleted=''n'' and  plnmstr.is_deleted=''n'') as plan order by plan.plan_id ,plan.service_code,plan.charge_code', 'Plan wise services', '0', '1');


insert ignore into stretchy_report values(null, 'Collection_Day_wise_Details', 'Table', '', 'Invoice&Collections', 'select  off.office_type,off.name as office_Name,pay.payment_date as Date,pay.paymode_id as Paymode,clnt.display_name as clientName,sum(ifnull(pay.amount_paid,0)) as Amount_Collection from m_office off  join  m_client clnt on off.id=clnt.office_id left outer join b_payments pay on clnt.id=pay.client_id group by  pay.payment_date order by  off.office_type,pay.payment_date', 'Collections From Clients---Day wise details', '0', '1');

insert ignore into stretchy_report values(null,'Collection_Month_wise_Summary', 'Table','','Invoice&Collections', 'select off.office_type,off.name as office_Name,pay.paymode_id as Paymode,sum(ifnull(pay.amount_paid,0)) as Amount_Collection,Year(pay.payment_date) AS Years,monthname(pay.payment_date) AS Months from m_office off  join m_client clnt on off.id=clnt.office_id join b_payments pay on clnt.id=pay.client_id group by Years,Months order by Year(pay.payment_date)','Collection from clients -- Month wise summary', '0', '1');


CREATE or replace VIEW `stock_available_vw` AS select `o`.`hierarchy` AS `hierarchy`,`id`.`office_id` AS `officeId`,`o`.`name` AS `Branch`,`mcv`.`code_value` AS `officeType`,`s`.`supplier_description` AS `Supplier`,`im`.`item_code` AS `ItemCode`,`im`.`item_description` AS `ItemName`,`id`.`serial_no` AS `SerialNo`,`id`.`provisioning_serialno` AS `ProvSerNo`,`id`.`quality` AS `Quality`,cast(`g`.`purchase_date` as date) AS `PURCHASE DATE`  from (((((`b_grn` `g` join `b_supplier` `s` on((`g`.`supplier_id` = `s`.`id`))) join `b_item_master` `im` on((`g`.`item_master_id` = `im`.`id`))) join `b_item_detail` `id` on(((`im`.`id` = `id`.`item_master_id`) and (`id`.`status` = 'Available')))) left join `m_office` `o` on((`id`.`office_id` = `o`.`id`))) left join `m_code_value` `mcv` on(((`mcv`.`code_id` = 46) and (`mcv`.`id` = `o`.`office_type`))));

CREATE or replace VIEW `hw_alloc_vw` AS select distinct `c`.`office_id` AS `OfficeId`,`mo`.`name` AS `OfficeName`,`c`.`id` AS `ClientID`,`c`.`display_name` AS `ClientName`,`im`.`item_code` AS `ItemCode`,`im`.`item_description` AS `Description`,`a`.`serial_no` AS `SerialNo`,`id`.`provisioning_serialno` AS `ProvisioningNo`,cast(`a`.`allocation_date` as date) AS `AllocationDate`,`bos`.`sale_date` AS `SaleDate`,`im`.`unit_price` AS `SalePrice`,`id`.`status` AS `Status`,`im`.`warranty` AS `Warranty`,cast(`id`.`warranty_date` as date) AS `WarrantyExpiryDate` from ((((((`m_client` `c` join `b_client_address` `ca` on(((`c`.`id` = `ca`.`client_id`) and (`ca`.`address_key` = 'PRIMARY')))) join `b_allocation` `a` on(((`c`.`id` = `a`.`client_id`) and (`a`.`is_deleted` = 'N')))) join `b_item_detail` `id` on((`id`.`serial_no` = `a`.`serial_no`))) join `b_item_master` `im` on((`id`.`item_master_id` = `im`.`id`))) join `b_onetime_sale` `bos` on(((`bos`.`client_id` = `id`.`client_id`) and (`bos`.`item_id` = `im`.`id`)))) join `m_office` `mo` on((`c`.`office_id` = `mo`.`id`)));

update stretchy_report set report_sql='select * FROM hw_alloc_vw  where `AllocationDate`  between ''${startDate}'' and ''${endDate}''and  (OfficeId = ''${officeId}'' or -1 = ''${officeId}'')  '
where report_name='List of HardWare Allocations';

update stretchy_report set report_sql='select * from stock_available_vw where (`officeId` = ''${officeId}'' or -1 = ''${officeId}'')  '
where report_name='Stock Item Details';

update stretchy_report set report_sql='select off.office_type,off.name as office_Name,pay.paymode_id as Paymode,sum(ifnull(pay.amount_paid,0)) as Amount_Collection,Year(pay.payment_date) AS Years,monthname(pay.payment_date) AS Months from m_office off  join m_client clnt on off.id=clnt.office_id join b_payments pay on clnt.id=pay.client_id group by Years,Months order by Year(pay.payment_date)' where report_name='Collection_Month_wise_Summary';

CREATE or replace VIEW `br_stock_summary` AS select s.supplier_description Supplier,g.office_id,(select o.name from m_office o where o.id=g.office_id) Receiver,`im`.`item_description` AS `Item`,date_format(`g`.`purchase_date`, '%Y-%M') AS `PurchaseMonth`,cast(`g`.`orderd_quantity` as char) AS `OrderedQty`,cast(`g`.`received_quantity` as char ) AS `ReceivedQty`,cast(`mrn`.`received_quantity` as char ) AS `TransferQty`,cast(sum(ifnull(`ots`.`quantity`,0) ) as char ) AS `SaleQty`,cast((`g`.`received_quantity` - sum(ifnull(`ots`.`quantity`,0))-ifnull(`mrn`.`received_quantity`,0) ) as char) AS `stock_bal` from b_grn g left join `b_supplier` `s` ON ((`g`.`supplier_id` = `s`.`id`)) left join `b_item_master` `im` ON ((`g`.`item_master_id` = `im`.`id`)) left join b_mrn mrn on (im.id = mrn.item_master_id AND mrn.from_office=g.office_id)  left join `b_onetime_sale` `ots` on (im.id=`ots`.`item_id` and ots.office_id=g.office_id  and ots.is_deleted ='N') UNION ALL  select (select o.name from m_office o where o.id=mrn.from_office) Supplier,coalesce(mrn.to_office,ots.office_id) office_id,(select o.name from m_office o where o.id=mrn.to_office) Receiver, `im`.`item_description` AS `Item`, date_format(`mrn`.`requested_date`, '%Y-%M') AS `PurchaseMonth`,cast(`mrn`.`orderd_quantity` as char) AS `OrderedQty`,cast(`mrn`.`received_quantity` as char ) AS `ReceivedQty`,cast(ifnull(`mrf`.`received_quantity`,0) as char ) AS `TransferQty`,cast(sum(ifnull(`ots`.`quantity`,0)) as char ) AS `SaleQty`,cast((`mrn`.`received_quantity` - sum(ifnull(`ots`.`quantity`,0)) -ifnull(`mrf`.`received_quantity`,0)) as char) AS `stock_bal` from `b_item_master` `im` join b_mrn mrn on (im.id = mrn.item_master_id ) left join b_mrn mrf on (im.id = mrf.item_master_id and mrn.to_office = mrf.from_office) left join `b_onetime_sale` `ots` on (im.id=`ots`.`item_id` and ots.office_id=mrn.to_office ) group by  ots.office_id;

update stretchy_report set report_sql='select custinv.client_id as Customer_id,custinv.Name,custinv.office_id,custinv.office,custinv.invoice_date,custinv.Total_invoice  ,adjust.debitadjust,adjust.creditadjust,ifnull(cast(round(sum(pay.amount_paid),2)as char) ,0)as Total_Collection,cast(round(custinv.Total_invoice - ifnull(sum(pay.amount_paid),0) + ifnull(adjust.debitadjust,0) - ifnull(adjust.creditadjust,0))as char) as Balance from ( select cust.account_no as Customer_Id,cust.display_name as Name,cust.id as client_id,off.id as office_id,off.name as  Office,inv.invoice_date,cast(round(sum(inv.invoice_amount),2)as char)  as Total_invoice from m_client cust,m_office off,b_invoice inv  where cust.office_id=off.id and cust.id=inv.client_id group by cust.id Order by cust.id ) custinv  left outer join  b_payments pay on custinv.client_id=pay.client_id left outer join ( SELECT ADJ.CLIENT_ID,sum(ADJ.DBADJ) as debitadjust,sum(ADJ.CRADJ) as creditadjust FROM (SELECT client_id,adjustment_type,SUM((CASE adjustment_type WHEN ''DEBIT'' THEN adjustment_amount ELSE 0 END )) AS DBADJ, SUM((CASE adjustment_type WHEN ''CREDIT'' THEN adjustment_amount ELSE 0 END )) AS CRADJ FROM b_adjustments GROUP BY client_id,adjustment_type) AS ADJ GROUP BY ADJ.CLIENT_ID) adjust on custinv.client_id=adjust.client_id group by custinv.client_id order by custinv.client_id'
where report_name='Customer Outstanding Report';

insert ignore into `stretchy_report` values (null,'Invoice_Datewise_Details','Table','','Invoice&Collections','select inv.id as Invoice_No,inv.invoice_date,inv.client_id,clnt.display_name as Client_Name,chrg.charge_type,chrg.charge_start_date,chrg.charge_end_date,cast(round(sum(chrg.charge_amount),2)as char) as Charge_Amount,cast(round(chrg.discount_amount,2) as char)  as Discount,cast(round(sum(ifnull(chrgtax.Tax_amount,0)),2) as char) as TaxAmount,cast(round(((chrg.charge_amount) + sum(ifnull(chrgtax.Tax_amount,0)) -chrg.discount_amount),2)as char) as Invoice_Amount from b_invoice inv   join m_client clnt on inv.client_id=clnt.id join b_charge chrg  on inv.client_id=chrg.client_id and inv.id=chrg.invoice_id left outer join b_charge_tax chrgtax on chrg.invoice_id=chrgtax.invoice_id and chrg.id=chrgtax.charge_id group by inv.id','Invoice Date Wise Details',0,1);

insert ignore into `stretchy_report` values (null,'Invoice_Monthwise_Summary','Table','','Invoice&Collections','select year(inv.invoice_date) as Inv_Year,monthname(inv.invoice_date) as Month_inv,chrg.charge_type,cast(round(sum(chrg.charge_amount),2) as char) as Charge_Amount,cast(round(chrg.discount_amount,2) as char)  as Discount,cast(round(sum(ifnull(chrgtax.Tax_amount,0)),2)as char) as TaxAmount,cast(round((sum(chrg.charge_amount) + sum(ifnull(chrgtax.Tax_amount,0)) -chrg.discount_amount),2) as char) as Invoice_Amount from  b_invoice inv join m_client clnt on inv.client_id=clnt.id join b_charge chrg on inv.client_id=chrg.client_id and inv.id=chrg.invoice_id left outer join b_charge_tax chrgtax on   chrg.invoice_id=chrgtax.invoice_id and chrg.id=chrgtax.charge_id group by  year(inv.invoice_date) ,monthname(inv.invoice_date) order by year(inv.invoice_date) ,monthname(inv.invoice_date)','Invoice Monthwise Summary',0,1);
insert ignore into `stretchy_report` values (null,'Plan_Wise_Revenue_Detail','Table','','Invoice&Collections','SELECT plnmst.plan_description Plan_Name,invc.id Invoice_no,invc.Invoice_date,chrg.client_id,clnt.display_name ClientName,chrg.charge_start_date Charge_From,chrg.charge_end_date Charge_To,cast(round(chrg.charge_amount,2) as char) charge_amount,cast(round(chrg.discount_amount,2)as char) discount_amount,cast(round(ifnull(tax.Tax_amount,0),2) as char)  Tax_amount,cast(round(invc.invoice_amount,2) as char) invoice_amount FROM b_plan_master plnmst JOIN b_orders ord ON plnmst.id = ord.plan_id JOIN b_charge chrg ON chrg.order_id = ord.id JOIN b_invoice invc ON invc.client_id = chrg.client_id AND invc.id = chrg.invoice_id AND charge_type = ''RC'' JOIN m_client clnt ON clnt.id = invc.client_id LEFT OUTER JOIN b_charge_tax tax ON tax.charge_id = chrg.id GROUP BY plnmst.id, invc.id ORDER BY invc.id','Plan Wise Revenue Detail',0,1);
insert ignore into `stretchy_report` values (null,'Plan_wise_Revenue_MonthWise','Table','','Invoice&Collections','SELECT plnmst.plan_description Plan_Name,Monthname(invc.Invoice_date) AS Month,cast(round(sum(chrg.charge_amount),2)as char) ChargeAmount,cast(round(sum(chrg.discount_amount),2)as char) Discount_Amount,cast(round(sum(ifnull(tax.Tax_amount, 0)),2)as char) TaxAmount,cast(round((sum(chrg.charge_amount)- sum(chrg.discount_amount)+ sum(ifnull(tax.Tax_amount, 0))),2) as char )AS invoice_amount FROM b_plan_master plnmst JOIN b_orders ord ON plnmst.id = ord.plan_id JOIN b_charge chrg ON chrg.order_id = ord.id JOIN b_invoice invc ON     invc.client_id = chrg.client_id AND invc.id = chrg.invoice_id AND charge_type = ''RC'' JOIN m_client clnt ON clnt.id = invc.client_id LEFT OUTER JOIN b_charge_tax tax ON tax.charge_id = chrg.id GROUP BY Monthname(invc.Invoice_date), plnmst.id','Plan wise Revenue Month Wise',0,1);

CREATE OR REPLACE VIEW `city_order_plan_vw` AS select `ca`.`country` AS `COUNTRY`,`ca`.`city` AS `CITY`,c.office_id,`of`.`name` AS `Branch`,`c`.`display_name` AS `CLIENT NAME`,`pm`.`plan_description` AS `PlanName` , o.id OrderId,ev.enum_value OrderStatus ,`bcp`.`contract_period` AS `CONTRACT PERIOD`,cast(`o`.`start_date` as date) AS `START DATE`,cast(`o`.`end_date` as date) AS `END DATE`,`o`.`billing_frequency` AS `BILLING FREQUENCY`,bop.price  from `b_orders` `o` left join r_enum_value ev on ( o.order_status=ev.enum_id and ev.enum_name='order_status') left join b_order_price bop on (o.id = bop.order_id )
 left join b_contract_period bcp on (o.contract_period = bcp.id) left join `m_client` `c` on((`o`.`client_id` = `c`.`id`)) left join `b_plan_master` `pm` on((`o`.`plan_id` = `pm`.`id`))  left join `m_office` `of` on((`c`.`office_id` = `of`.`id`)) left join `b_client_address` `ca` on(((`ca`.`client_id` = `c`.`id`) and (`ca`.`address_key` = 'PRIMARY'))) where (`o`.`is_deleted` = 'n');


Update stretchy_report set report_sql = 'select a.* from city_order_plan_vw a,m_office o where a.branch=o.name and `START DATE`  between ''${startDate}'' and ''${endDate}'' and  (o.id = ''${officeId}'' or -1 = ''${officeId}'') ' where report_name='City Wise Orders';

-- List of Device Sales --

Update stretchy_report set report_sql = 'SELECT o.name Branch ,a.account_no `AccountNo`,CASE when status_enum=100 then ''New'' when status_enum=300 then "Active" when status_enum=600 then "Deactive" else status_enum END as Status, a.display_name `ClientName`, im.item_description `Device` ,date_format(b.sale_date,''%Y-%m-%d'') SaleDate, b.total_price SalePrice FROM m_client a, b_onetime_sale b , m_office o , b_item_master im WHERE a.id = b.client_id and a.office_id = o.id and b.item_id = im.id AND b.sale_date between ''${startDate}'' and ''${endDate}'' order by b.sale_date' where report_name='List of Device Sales';

--  List of Disconnections --

CREATE or replace  VIEW `discon_vw` AS select distinct `c`.`office_id` AS `OFFICEID`,`mo`.`name` AS `BRANCH`,`c`.`account_no` AS `ACCOUNT NO`,`c`.`display_name` AS `CLIENT NAME`,`c`.`phone` AS `PHONE NO`,`pm`.`plan_description` AS `PLAN`, `bcp`.`contract_period` AS `CONTRACT PERIOD`,`o`.`billing_frequency` AS `BILL FRQUENCY`,cast(`c`.`activation_date` as date) AS `ACTIVATION DATE`,cast(`oh`.`actual_date` as date) AS `DISCONNECTION DATE`,(to_days(`oh`.`actual_date`) - to_days(`c`.`activation_date`)) AS `NO OF DAYS`,
`op`.`price` AS `PRICE` ,o.disconnect_reason,(select max(`x`.`hw_serial_no`) from `b_association` `x` where ((`c`.`id` = `x`.`client_id`) and (`x`.`is_deleted` = 'N'))) AS `DEVICE` from ((((((`m_client` `c`  join `m_office` `mo` on((`c`.`office_id` = `mo`.`id`)))  join `b_client_address` `ca` on((`c`.`id` = `ca`.`client_id`)))  join `b_orders` `o` on((`c`.`id` = `o`.`client_id`))) left join b_contract_period bcp on (o.contract_period = bcp.id) join `b_orders_history` `oh` on((`o`.`id` = `oh`.`order_id`))) left join `b_plan_master` `pm` on((`o`.`plan_id` = `pm`.`id`))) left join `b_order_price` `op` on((`o`.`id` = `op`.`order_id`))) 
 where ((`o`.`id` = (select max(`o2`.`id`) from `b_orders` `o2`  where (`o2`.`client_id` = `o`.`client_id`)  and o2.user_action = 'DISCONNECTION' )) and (`oh`.`id` =  (select max(`oh2`.`id`) from `b_orders_history` `oh2` where ((`oh2`.`transaction_type` = 'DISCONNECTION')  and (`oh2`.`order_id` = `oh`.`order_id`)))));

-- Plan-wise Orders Chart --

Update stretchy_report set report_sql = 'select `PLAN DESCRIPTION`,(`ORDER COUNT`) `ORDER COUNT` from plan_orders_vw GROUP BY `PLAN DESCRIPTION` ' where report_name='Plan-wise Orders Chart';

CREATE OR REPLACE VIEW `plan_orders_vw` AS select  `pm`.`plan_code` AS `PLAN_CODE`, `pm`.`plan_description` AS `PLAN DESCRIPTION`,`pd`.`service_code` AS `SERVICE CODE`,`o`.`transaction_type` AS `TRANSACTION TYPE`,`o`.`billing_frequency` AS `BILLING FREQUENCY`,count(`o`.`client_id`) AS `CLIENT COUNT`,`o`.`order_status` AS `ORDER STATUS`,`o`.`contract_period` AS `CONTRACT PERIOD`,count(`ol`.`order_id`) AS `ORDER COUNT` from ((((`b_order_line` `ol` join `b_service` `s` ON ((`ol`.`service_id` = `s`.`id`))) join `b_plan_detail` `pd` ON ((`pd`.`service_code` = `s`.`service_code`))) join `b_plan_master` `pm` ON ((`pd`.`plan_id` = `pm`.`id`))) join `b_orders` `o` ON (((`o`.`plan_id` = `pm`.`id` and o.order_status=1)
 and (`ol`.`order_id` = `o`.`id`)))) where (`o`.`is_deleted` = 'n') group by `pm`.`plan_code` , `pm`.`plan_description` , `o`.`transaction_type` , `pd`.`service_code` , `o`.`transaction_type` , `o`.`billing_frequency` , `ol`.`service_status`;


-- PaymodeCollection Chart -- 

Update stretchy_report set report_sql = 'select mcv.code_value PayMode ,round(sum(p.amount_paid),2) Collection from b_payments p, m_code_value mcv ,m_client c, m_office of where p.paymode_id=mcv.id and mcv.code_id=11 AND date_format(`payment_date`,''%Y-%m'')=date_format(now(),''%Y-%m'') and p.client_id=c.id  and c.office_id=of.id and  ((of.id = ''${officeId}'') or (-1 = ''${officeId}'')) group by mcv.code_value ' where report_name='PaymodeCollection Chart';

-- Cumulative Customer Chart--
Update stretchy_report set report_sql = 'select ev.enum_value status ,count(distinct o.client_id ) clients ,count(distinct o.id ) orders from b_orders o,r_enum_value ev, m_client c, m_office of  where o.order_status=ev.enum_id and o.client_id=c.id  and c.office_id=of.id and ev.enum_name=''order_status'' and  ((of.id = ''${officeId}'') or (-1 = ''${officeId}'')) group by order_status' where report_name='CumulativeCustomersChart';

CREATE OR REPLACE VIEW  `city_order_plan_vw` AS select `ca`.`country` AS `COUNTRY`,`ca`.`city` AS `CITY`,c.office_id,`of`.`name` AS `Branch`,`c`.`display_name` AS `CLIENT NAME`,`pm`.`plan_description` AS `PlanName` , o.id OrderId,ev.enum_value OrderStatus ,`bcp`.`contract_period` AS `CONTRACT PERIOD`,cast(`o`.`start_date` as date) AS `START DATE`,cast(`o`.`end_date` as date) AS `END DATE`,`o`.`billing_frequency` AS `BILLING FREQUENCY`,bop.price  from  `b_orders` `o` left join r_enum_value ev on ( o.order_status=ev.enum_id and ev.enum_name='order_status') left join b_order_price bop on (o.id = bop.order_id ) left join b_contract_period bcp on (o.contract_period = bcp.id) left join  `m_client` `c` on((`o`.`client_id` = `c`.`id`)) left join  `b_plan_master` `pm` on((`o`.`plan_id` = `pm`.`id`))  left join  `m_office` `of` on((`c`.`office_id` = `of`.`id`)) left join  `b_client_address` `ca` on(((`ca`.`client_id` = `c`.`id`) and (`ca`.`address_key` = 'PRIMARY'))) where (`o`.`is_deleted` = 'n');

Update stretchy_report set report_sql = 'select a.* from city_order_plan_vw a,m_office o where a.branch=o.name and `START DATE`  between ''${startDate}'' and ''${endDate}'' and  (o.id = ''${officeId}'' or -1 = ''${officeId}'') ' where  report_name  = 'City Wise Orders';

Update stretchy_report set report_sql = 'select ev.enum_value status ,count(distinct o.client_id ) clients ,count(distinct o.id ) orders from b_orders o,r_enum_value ev, m_client c, m_office of where o.order_status=ev.enum_id and o.client_id=c.id and c.office_id=of.id and ev.enum_name=''order_status'' and  ((of.id = ''${officeId}'') or (-1 = ''${officeId}'')) group by order_status' where report_name  ='CumulativeCustomersChart';

Update stretchy_report set report_sql ='SELECT o.name Branch ,a.account_no `AccountNo`,CASE when status_enum=100 then ''New'' when status_enum=300 then "Active" when status_enum=600 then "Deactive" else status_enum END as Status, a.display_name `ClientName`, im.item_description `Device` ,date_format(b.sale_date,''%Y-%m-%d'') SaleDate, b.total_price SalePrice  FROM m_client a, b_onetime_sale b , m_office o , b_item_master im  WHERE a.id = b.client_id  and a.office_id = o.id and b.item_id = im.id AND b.sale_date between ''${startDate}'' and ''${endDate}''  order by b.sale_date ' where report_name = 'List of Device Sales';

CREATE or replace  VIEW  `discon_vw` AS select distinct `c`.`office_id` AS `OFFICEID`,`mo`.`name` AS `BRANCH`,`c`.`account_no` AS `ACCOUNT NO`,`c`.`display_name` AS `CLIENT NAME`,`c`.`phone` AS `PHONE NO`,`pm`.`plan_description` AS `PLAN`, `bcp`.`contract_period` AS `CONTRACT PERIOD`,`o`.`billing_frequency` AS `BILL FRQUENCY`,cast(`c`.`activation_date` as date) AS `ACTIVATION DATE`,cast(`oh`.`actual_date` as date) AS `DISCONNECTION DATE`,(to_days(`oh`.`actual_date`) - to_days(`c`.`activation_date`)) AS `NO OF DAYS`,`op`.`price` AS `PRICE` ,o.disconnect_reason,(select max(`x`.`hw_serial_no`) from  `b_association` `x` where ((`c`.`id` = `x`.`client_id`) and (`x`.`is_deleted` = 'N'))) AS `DEVICE` from (((((( `m_client` `c` join  `m_office` `mo` on((`c`.`office_id` = `mo`.`id`))) join  `b_client_address` `ca` on((`c`.`id` = `ca`.`client_id`))) join  `b_orders` `o` on((`c`.`id` = `o`.`client_id`))) left join b_contract_period bcp on (o.contract_period = bcp.id) join  `b_orders_history` `oh` on((`o`.`id` = `oh`.`order_id`))) left join  `b_plan_master` `pm` on((`o`.`plan_id` = `pm`.`id`)))  left join  `b_order_price` `op` on((`o`.`id` = `op`.`order_id`)))  where ((`o`.`id` = (select max(`o2`.`id`) from  `b_orders` `o2` where (`o2`.`client_id` = `o`.`client_id`)  and o2.user_action = 'DISCONNECTION' )) and (`oh`.`id` = (select max(`oh2`.`id`) from  `b_orders_history` `oh2` where ((`oh2`.`transaction_type` = 'DISCONNECTION') and (`oh2`.`order_id` = `oh`.`order_id`)))));

SET @offId=(SELECT id FROM stretchy_parameter where parameter_label='Office');

SET @id = (select id from stretchy_report where report_name='PaymodeCollection Chart');

insert ignore into stretchy_report_parameter(report_id,parameter_id,report_parameter_name)values (@id,@offId,'OfficeId');

Update stretchy_report set report_sql ='select mcv.code_value PayMode ,round(sum(p.amount_paid),2) Collection from b_payments p, m_code_value mcv ,m_client c, m_office of where p.paymode_id=mcv.id and mcv.code_id=11 AND date_format(`payment_date`,''%Y-%m'')=date_format(now(),''%Y-%m'') and p.client_id=c.id and c.office_id=of.id and  ((of.id = ''${officeId}'') or (-1 = ''${officeId}'')) group by mcv.code_value ' where report_name = 'PaymodeCollection Chart' ;

---- Plan wise order chart

CREATE OR REPLACE VIEW `plan_orders_vw` AS select `pm`.`plan_code` AS `PLAN_CODE`,`pm`.`plan_description` AS `PLAN DESCRIPTION`,`pd`.`service_code` AS `SERVICE CODE`,`o`.`transaction_type` AS `TRANSACTION TYPE`,`o`.`billing_frequency` AS `BILLING FREQUENCY`,count(`o`.`client_id`) AS `CLIENT COUNT`,`o`.`order_status` AS `ORDER STATUS`,`o`.`contract_period` AS `CONTRACT PERIOD`,count(`ol`.`order_id`) AS `ORDER COUNT` from ((((`b_order_line` `ol` join `b_service` `s` ON ((`ol`.`service_id` = `s`.`id`))) join `b_plan_detail` `pd` ON ((`pd`.`service_code` = `s`.`service_code`))) join `b_plan_master` `pm` ON ((`pd`.`plan_id` = `pm`.`id`))) join `b_orders` `o` ON (((`o`.`plan_id` = `pm`.`id` and o.order_status=1) and (`ol`.`order_id` = `o`.`id`)))) where (`o`.`is_deleted` = 'n') group by `pm`.`plan_code` , `pm`.`plan_description` ,  `o`.`transaction_type` , `pd`.`service_code` , `o`.`transaction_type` , `o`.`billing_frequency` , `ol`.`service_status`;

Update stretchy_report set report_sql = 'select `PLAN DESCRIPTION`,(`ORDER COUNT`) `ORDER COUNT` from plan_orders_vw  GROUP BY `PLAN DESCRIPTION` ' where report_name='Plan-wise Orders Chart';







