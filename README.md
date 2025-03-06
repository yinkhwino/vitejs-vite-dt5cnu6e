# Inventory Optimiser

Program for calculating the optimal time to order plane parts involves considering factors like lead time, inventory levels, demand forecasts, and possibly cost.

1. User Signin ✅️
2. redirect to Plane part page ✅️
2.1 order page will route to Order page 🚫
3. User sign out on every session ✅️

Here’s a simplified approach:  
• PlanePart Interface: Defines the structure of a part in the inventory, including key metrics for ordering decisions. 

14-feb: migrations of components 
15-28feb: AI models development 

• Order Interface: Defines what an order looks like (part number and quantity).

• InventoryOptimizer Class: Manages the logic for:  
• calculateEOQ: Uses the Economic Order Quantity formula to determine how much to order at once, balancing holding costs against ordering costs. The following formula will be using:
EOQ = 2SD/H where S is ordering cost, D is demand annually, H for holding cost

• calculateReorderPoint: Decides when to order based on lead time and demand, ensuring there’s enough stock during the lead time.  
As per my simple aeroplane case analysis, Blade parts will have estimated lead times of at least 4 hours and 1.75 cycles.

• shouldOrder: Checks if the current stock level suggests an order should be made.
• suggestOrders: Looks at all parts and returns an array of suggested orders.

@tanstack dependencies 

|package.json 
Add "dependencies": {"@supabase/supabase-js": "^2.39.7", "@tanstack/vue-query": "^5.28.4", "axios": "^1.6.7",}
|src
    |App.vue 
    |components / ChatWidget.vue 
    |components / ParametersForm.vue
    |views/ Dashboard.vue 
    |Server.js 