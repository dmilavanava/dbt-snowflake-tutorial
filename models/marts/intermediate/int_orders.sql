with stg_orders as (

    select * from {{ ref('stg_orders') }}
),

final as (

    select
        order_id,
        customer_id,
        order_placed_at,
        order_status,

        min(order_placed_at) over (partition by customer_id) as first_order_date,
        max(order_placed_at) over (partition by customer_id) as most_recent_order_date,
        count(order_id) over (partition by customer_id) as number_of_orders,
        case 
            when first_order_date = order_placed_at then 'new'
            else 'return' 
        end as new_vs_return,
        row_number() over (partition by customer_id order by order_id) as customer_sales_seq

    from stg_orders

)

select * from final
