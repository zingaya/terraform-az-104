                        +--------------------------+
                        |       RESOURCE GROUP      |
                        |        (var.rg_name)      |
                        +--------------------------+
                                   |
                    +-----------------------------+
                    |       Virtual Network        |
                    |    (10.0.0.0/23)             |
                    +-----------------------------+
                     |                           |
           +-------------------+         +-------------------+
           |   Subnet main0    |         |   Subnet main1    |
           |   (10.0.0.0/24)   |         |   (10.0.1.0/24)   |
           +-------------------+         +-------------------+
           |           |           \                 |
+----------+           +------------+         +-----+-----+
|                          |                  |           |
NIC web1 (in web_asg)  NIC web2 (web_asg)  NIC admin1  (admin subnet)
NIC sql1 (sql_asg)    NIC sql2 (sql_asg)

--------------------------------------------------------
|                  Network Security Group (NSG)         |
|                       nsg-main                         |
|  ----------------------------------------------------  |
|  Deny-All-Inbound (default deny all inbound traffic)  |
|                                                       |
|  Allow-SSH-From-Admin-Subnet (only 10.0.1.0/24 -> port 22)  |
|                                                       |
|  Allow-MySQL-From-Web-ASG (web_asg -> sql_asg port 3306)  |
|                                                       |
|  Allow-HTTP-Admin (10.0.1.0/24 -> web_asg port 8080)      |
---------------------------------------------------------

Legend:
- web_asg: Application Security Group for web server NICs (web1, web2)
- sql_asg: Application Security Group for SQL server NICs (sql1, sql2)
- admin subnet: subnet main1 (10.0.1.0/24) where admin NICs reside
- NSG rules implement least privilege:
   * Deny all inbound by default
   * Allow SSH only from admin subnet
   * Allow MySQL only from web_asg to sql_asg
   * Allow HTTP on 8080 only from admin subnet to web_asg
