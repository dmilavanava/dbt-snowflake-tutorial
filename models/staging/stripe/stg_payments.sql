with source as (

   select * from {{ source('stripe', 'payment') }}
),

transformed as (

     select
        id as payment_id,
        orderid as order_id,
        paymentmethod as payment_method,
        status,
        amount,
        created
    
    from source

)

select * from transformed