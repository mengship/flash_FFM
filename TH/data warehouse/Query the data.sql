select
                if(off_date='2025-05-12', '2025-05-11', off_date) off_date
            from
            fle_staging.sys_holiday
            where deleted = 0
                and company_category='2'
                and off_date between date_sub(date(now() + interval -1 hour),interval 30 day) and date_add(date(now() + interval -1 hour), interval 30 day)
            group by off_date