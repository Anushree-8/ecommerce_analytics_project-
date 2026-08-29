import pandas as pd
import matplotlib.pyplot as plt

orders = pd.read_csv("../data/orders.csv", parse_dates=["order_date"])
customers = pd.read_csv("../data/customers.csv")
products = pd.read_csv("../data/products.csv")

df = orders.merge(customers, on="customer_id").merge(products, on="product_id")

print("Total Revenue:", round(df["sales"].sum(),2))
print("Total Profit:", round(df["profit"].sum(),2))

monthly = df.groupby(df["order_date"].dt.to_period("M"))["sales"].sum()
monthly.plot(title="Monthly Revenue Trend")
plt.xlabel("Month")
plt.ylabel("Revenue")
plt.tight_layout()
plt.show()

category = df.groupby("category")["sales"].sum().sort_values(ascending=False)
category.plot(kind="bar", title="Revenue by Category")
plt.xlabel("Category")
plt.ylabel("Revenue")
plt.tight_layout()
plt.show()
