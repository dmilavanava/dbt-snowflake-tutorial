with customers as (

    select * from {{ ref('stg_customers') }}

),

orders as (

    select * from {{ ref('int_orders') }}

),

payments as (

    select * from {{ ref('int_payments') }}

),

final as (
    
    select 
        orders.order_id,
        orders.customer_id,
        orders.order_placed_at,
        orders.order_status,
        orders.first_order_date,
        orders.most_recent_order_date,
        orders.number_of_orders,
        orders.new_vs_return,
        orders.customer_sales_seq,
        payments.total_amount_paid,
        payments.payment_finalized_date,
        customers.customer_first_name,
        customers.customer_last_name,
        sum(payments.total_amount_paid) over (
            partition by orders.customer_id order by orders.order_id 
            rows between unbounded preceding and current row) as customer_lifetime_value 

    from orders
    left join payments
        on orders.order_id = payments.order_id
    left join customers
        on orders.customer_id = customers.customer_id

)

select * from final