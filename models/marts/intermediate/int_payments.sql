with stg_payments as (

    select * from {{ ref('stg_payments') }}

),

final as (

    select
        order_id,
        max(created) as payment_finalized_date, 
        round(sum(amount) / 100.0, 2) as total_amount_paid
    
    from stg_payments
    where status <> 'fail'
    group by 1

)

select * from final