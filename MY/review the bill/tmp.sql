
# select
# 	left(DATE_SUB(current_date, INTERVAL 1 MONTH), 7) datemonth
#     ,t.type
#     ,t.计费规则 as rule
#     ,t.seller_name
#     ,t.warehouse_name
# 	,sum(order_sum) as order_sum
#     ,sum(t.amount) as calculate_amt
#
# from(
	WITH price1 AS
		(
		SELECT
        	distinct
			ebrr.seller_id
			-- ,ebrr.warehouse_id
			,ebr.weight_volume_convert
			,1-(ebr.delivery_discount_rate/100) as discount_rate

			,CAST(JSON_EXTRACT(rule_datail, '$[0].weight') AS DOUBLE) AS weight0
			,CAST(JSON_EXTRACT(rule_datail, '$[0].r01') AS DOUBLE) AS r010
			,CAST(JSON_EXTRACT(rule_datail, '$[0].r02') AS DOUBLE) AS r020
			,CAST(JSON_EXTRACT(rule_datail, '$[0].r03') AS DOUBLE) AS r030
			,CAST(JSON_EXTRACT(rule_datail, '$[0].r04') AS DOUBLE) AS r040
			,CAST(JSON_EXTRACT(rule_datail, '$[0].r05') AS DOUBLE) AS r050
			,CAST(JSON_EXTRACT(rule_datail, '$[0].r06') AS DOUBLE) AS r060
			,CAST(JSON_EXTRACT(rule_datail, '$[0].r07') AS DOUBLE) AS r070
			,CAST(JSON_EXTRACT(rule_datail, '$[0].r08') AS DOUBLE) AS r080
			,CAST(JSON_EXTRACT(rule_datail, '$[0].r09') AS DOUBLE) AS r090
			,CAST(JSON_EXTRACT(rule_datail, '$[0].r10') AS DOUBLE) AS r100
			,CAST(JSON_EXTRACT(rule_datail, '$[0].r11') AS DOUBLE) AS r110
			,CAST(JSON_EXTRACT(rule_datail, '$[0].r12') AS DOUBLE) AS r120
			,JSON_EXTRACT(rule_datail, '$[0].type') AS type0
			,if(JSON_EXTRACT(rule_datail, '$[1].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[1].weight') AS DOUBLE)) AS weight1
			,if(JSON_EXTRACT(rule_datail, '$[1].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[1].r01') AS DOUBLE)) AS r011
			,if(JSON_EXTRACT(rule_datail, '$[1].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[1].r02') AS DOUBLE)) AS r021
			,if(JSON_EXTRACT(rule_datail, '$[1].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[1].r03') AS DOUBLE)) AS r031
			,if(JSON_EXTRACT(rule_datail, '$[1].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[1].r04') AS DOUBLE)) AS r041
			,if(JSON_EXTRACT(rule_datail, '$[1].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[1].r05') AS DOUBLE)) AS r051
			,if(JSON_EXTRACT(rule_datail, '$[1].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[1].r06') AS DOUBLE)) AS r061
			,if(JSON_EXTRACT(rule_datail, '$[1].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[1].r07') AS DOUBLE)) AS r071
			,if(JSON_EXTRACT(rule_datail, '$[1].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[1].r08') AS DOUBLE)) AS r081
			,if(JSON_EXTRACT(rule_datail, '$[1].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[1].r09') AS DOUBLE)) AS r091
			,if(JSON_EXTRACT(rule_datail, '$[1].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[1].r10') AS DOUBLE)) AS r101
			,if(JSON_EXTRACT(rule_datail, '$[1].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[1].r11') AS DOUBLE)) AS r111
			,if(JSON_EXTRACT(rule_datail, '$[1].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[1].r12') AS DOUBLE)) AS r121
			,JSON_EXTRACT(rule_datail, '$[1].type') AS type1
			,if(JSON_EXTRACT(rule_datail, '$[2].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[2].weight') AS DOUBLE)) AS weight2
			,if(JSON_EXTRACT(rule_datail, '$[2].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[2].r01') AS DOUBLE)) AS r012
			,if(JSON_EXTRACT(rule_datail, '$[2].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[2].r02') AS DOUBLE)) AS r022
			,if(JSON_EXTRACT(rule_datail, '$[2].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[2].r03') AS DOUBLE)) AS r032
			,if(JSON_EXTRACT(rule_datail, '$[2].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[2].r04') AS DOUBLE)) AS r042
			,if(JSON_EXTRACT(rule_datail, '$[2].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[2].r05') AS DOUBLE)) AS r052
			,if(JSON_EXTRACT(rule_datail, '$[2].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[2].r06') AS DOUBLE)) AS r062
			,if(JSON_EXTRACT(rule_datail, '$[2].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[2].r07') AS DOUBLE)) AS r072
			,if(JSON_EXTRACT(rule_datail, '$[2].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[2].r08') AS DOUBLE)) AS r082
			,if(JSON_EXTRACT(rule_datail, '$[2].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[2].r09') AS DOUBLE)) AS r092
			,if(JSON_EXTRACT(rule_datail, '$[2].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[2].r10') AS DOUBLE)) AS r102
			,if(JSON_EXTRACT(rule_datail, '$[2].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[2].r11') AS DOUBLE)) AS r112
			,if(JSON_EXTRACT(rule_datail, '$[2].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[2].r12') AS DOUBLE)) AS r122
			,JSON_EXTRACT(rule_datail, '$[2].type') AS type2
			,if(JSON_EXTRACT(rule_datail, '$[3].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[3].weight') AS DOUBLE)) AS weight3
			,if(JSON_EXTRACT(rule_datail, '$[3].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[3].r01') AS DOUBLE)) AS r013
			,if(JSON_EXTRACT(rule_datail, '$[3].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[3].r02') AS DOUBLE)) AS r023
			,if(JSON_EXTRACT(rule_datail, '$[3].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[3].r03') AS DOUBLE)) AS r033
			,if(JSON_EXTRACT(rule_datail, '$[3].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[3].r04') AS DOUBLE)) AS r043
			,if(JSON_EXTRACT(rule_datail, '$[3].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[3].r05') AS DOUBLE)) AS r053
			,if(JSON_EXTRACT(rule_datail, '$[3].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[3].r06') AS DOUBLE)) AS r063
			,if(JSON_EXTRACT(rule_datail, '$[3].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[3].r07') AS DOUBLE)) AS r073
			,if(JSON_EXTRACT(rule_datail, '$[3].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[3].r08') AS DOUBLE)) AS r083
			,if(JSON_EXTRACT(rule_datail, '$[3].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[3].r09') AS DOUBLE)) AS r093
			,if(JSON_EXTRACT(rule_datail, '$[3].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[3].r10') AS DOUBLE)) AS r103
			,if(JSON_EXTRACT(rule_datail, '$[3].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[3].r11') AS DOUBLE)) AS r113
			,if(JSON_EXTRACT(rule_datail, '$[3].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[3].r12') AS DOUBLE)) AS r123
			,JSON_EXTRACT(rule_datail, '$[3].type') AS type3
			,if(JSON_EXTRACT(rule_datail, '$[4].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[4].weight') AS DOUBLE)) AS weight4
			,if(JSON_EXTRACT(rule_datail, '$[4].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[4].r01') AS DOUBLE)) AS r014
			,if(JSON_EXTRACT(rule_datail, '$[4].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[4].r02') AS DOUBLE)) AS r024
			,if(JSON_EXTRACT(rule_datail, '$[4].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[4].r03') AS DOUBLE)) AS r034
			,if(JSON_EXTRACT(rule_datail, '$[4].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[4].r04') AS DOUBLE)) AS r044
			,if(JSON_EXTRACT(rule_datail, '$[4].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[4].r05') AS DOUBLE)) AS r054
			,if(JSON_EXTRACT(rule_datail, '$[4].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[4].r06') AS DOUBLE)) AS r064
			,if(JSON_EXTRACT(rule_datail, '$[4].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[4].r07') AS DOUBLE)) AS r074
			,if(JSON_EXTRACT(rule_datail, '$[4].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[4].r08') AS DOUBLE)) AS r084
			,if(JSON_EXTRACT(rule_datail, '$[4].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[4].r09') AS DOUBLE)) AS r094
			,if(JSON_EXTRACT(rule_datail, '$[4].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[4].r10') AS DOUBLE)) AS r104
			,if(JSON_EXTRACT(rule_datail, '$[4].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[4].r11') AS DOUBLE)) AS r114
			,if(JSON_EXTRACT(rule_datail, '$[4].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[4].r12') AS DOUBLE)) AS r124
			,JSON_EXTRACT(rule_datail, '$[4].type') AS type4
			,if(JSON_EXTRACT(rule_datail, '$[5].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[5].weight') AS DOUBLE)) AS weight5
			,if(JSON_EXTRACT(rule_datail, '$[5].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[5].r01') AS DOUBLE)) AS r015
			,if(JSON_EXTRACT(rule_datail, '$[5].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[5].r02') AS DOUBLE)) AS r025
			,if(JSON_EXTRACT(rule_datail, '$[5].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[5].r03') AS DOUBLE)) AS r035
			,if(JSON_EXTRACT(rule_datail, '$[5].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[5].r04') AS DOUBLE)) AS r045
			,if(JSON_EXTRACT(rule_datail, '$[5].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[5].r05') AS DOUBLE)) AS r055
			,if(JSON_EXTRACT(rule_datail, '$[5].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[5].r06') AS DOUBLE)) AS r065
			,if(JSON_EXTRACT(rule_datail, '$[5].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[5].r07') AS DOUBLE)) AS r075
			,if(JSON_EXTRACT(rule_datail, '$[5].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[5].r08') AS DOUBLE)) AS r085
			,if(JSON_EXTRACT(rule_datail, '$[5].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[5].r09') AS DOUBLE)) AS r095
			,if(JSON_EXTRACT(rule_datail, '$[5].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[5].r10') AS DOUBLE)) AS r105
			,if(JSON_EXTRACT(rule_datail, '$[5].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[5].r11') AS DOUBLE)) AS r115
			,if(JSON_EXTRACT(rule_datail, '$[5].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[5].r12') AS DOUBLE)) AS r125
			,JSON_EXTRACT(rule_datail, '$[5].type') AS type5
			,if(JSON_EXTRACT(rule_datail, '$[6].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[6].weight') AS DOUBLE)) AS weight6
			,if(JSON_EXTRACT(rule_datail, '$[6].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[6].r01') AS DOUBLE)) AS r016
			,if(JSON_EXTRACT(rule_datail, '$[6].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[6].r02') AS DOUBLE)) AS r026
			,if(JSON_EXTRACT(rule_datail, '$[6].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[6].r03') AS DOUBLE)) AS r036
			,if(JSON_EXTRACT(rule_datail, '$[6].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[6].r04') AS DOUBLE)) AS r046
			,if(JSON_EXTRACT(rule_datail, '$[6].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[6].r05') AS DOUBLE)) AS r056
			,if(JSON_EXTRACT(rule_datail, '$[6].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[6].r06') AS DOUBLE)) AS r066
			,if(JSON_EXTRACT(rule_datail, '$[6].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[6].r07') AS DOUBLE)) AS r076
			,if(JSON_EXTRACT(rule_datail, '$[6].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[6].r08') AS DOUBLE)) AS r086
			,if(JSON_EXTRACT(rule_datail, '$[6].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[6].r09') AS DOUBLE)) AS r096
			,if(JSON_EXTRACT(rule_datail, '$[6].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[6].r10') AS DOUBLE)) AS r106
			,if(JSON_EXTRACT(rule_datail, '$[6].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[6].r11') AS DOUBLE)) AS r116
			,if(JSON_EXTRACT(rule_datail, '$[6].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[6].r12') AS DOUBLE)) AS r126
			,JSON_EXTRACT(rule_datail, '$[6].type') AS type6
			,if(JSON_EXTRACT(rule_datail, '$[7].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[7].weight') AS DOUBLE)) AS weight7
			,if(JSON_EXTRACT(rule_datail, '$[7].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[7].r01') AS DOUBLE)) AS r017
			,if(JSON_EXTRACT(rule_datail, '$[7].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[7].r02') AS DOUBLE)) AS r027
			,if(JSON_EXTRACT(rule_datail, '$[7].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[7].r03') AS DOUBLE)) AS r037
			,if(JSON_EXTRACT(rule_datail, '$[7].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[7].r04') AS DOUBLE)) AS r047
			,if(JSON_EXTRACT(rule_datail, '$[7].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[7].r05') AS DOUBLE)) AS r057
			,if(JSON_EXTRACT(rule_datail, '$[7].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[7].r06') AS DOUBLE)) AS r067
			,if(JSON_EXTRACT(rule_datail, '$[7].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[7].r07') AS DOUBLE)) AS r077
			,if(JSON_EXTRACT(rule_datail, '$[7].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[7].r08') AS DOUBLE)) AS r087
			,if(JSON_EXTRACT(rule_datail, '$[7].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[7].r09') AS DOUBLE)) AS r097
			,if(JSON_EXTRACT(rule_datail, '$[7].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[7].r10') AS DOUBLE)) AS r107
			,if(JSON_EXTRACT(rule_datail, '$[7].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[7].r11') AS DOUBLE)) AS r117
			,if(JSON_EXTRACT(rule_datail, '$[7].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[7].r12') AS DOUBLE)) AS r127
			,JSON_EXTRACT(rule_datail, '$[7].type') AS type7
			,if(JSON_EXTRACT(rule_datail, '$[8].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[8].weight') AS DOUBLE)) AS weight8
			,if(JSON_EXTRACT(rule_datail, '$[8].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[8].r01') AS DOUBLE)) AS r018
			,if(JSON_EXTRACT(rule_datail, '$[8].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[8].r02') AS DOUBLE)) AS r028
			,if(JSON_EXTRACT(rule_datail, '$[8].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[8].r03') AS DOUBLE)) AS r038
			,if(JSON_EXTRACT(rule_datail, '$[8].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[8].r04') AS DOUBLE)) AS r048
			,if(JSON_EXTRACT(rule_datail, '$[8].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[8].r05') AS DOUBLE)) AS r058
			,if(JSON_EXTRACT(rule_datail, '$[8].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[8].r06') AS DOUBLE)) AS r068
			,if(JSON_EXTRACT(rule_datail, '$[8].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[8].r07') AS DOUBLE)) AS r078
			,if(JSON_EXTRACT(rule_datail, '$[8].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[8].r08') AS DOUBLE)) AS r088
			,if(JSON_EXTRACT(rule_datail, '$[8].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[8].r09') AS DOUBLE)) AS r098
			,if(JSON_EXTRACT(rule_datail, '$[8].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[8].r10') AS DOUBLE)) AS r108
			,if(JSON_EXTRACT(rule_datail, '$[8].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[8].r11') AS DOUBLE)) AS r118
			,if(JSON_EXTRACT(rule_datail, '$[8].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[8].r12') AS DOUBLE)) AS r128
			,JSON_EXTRACT(rule_datail, '$[8].type') AS type8
			,if(JSON_EXTRACT(rule_datail, '$[9].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[9].weight') AS DOUBLE)) AS weight9
			,if(JSON_EXTRACT(rule_datail, '$[9].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[9].r01') AS DOUBLE)) AS r019
			,if(JSON_EXTRACT(rule_datail, '$[9].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[9].r02') AS DOUBLE)) AS r029
			,if(JSON_EXTRACT(rule_datail, '$[9].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[9].r03') AS DOUBLE)) AS r039
			,if(JSON_EXTRACT(rule_datail, '$[9].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[9].r04') AS DOUBLE)) AS r049
			,if(JSON_EXTRACT(rule_datail, '$[9].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[9].r05') AS DOUBLE)) AS r059
			,if(JSON_EXTRACT(rule_datail, '$[9].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[9].r06') AS DOUBLE)) AS r069
			,if(JSON_EXTRACT(rule_datail, '$[9].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[9].r07') AS DOUBLE)) AS r079
			,if(JSON_EXTRACT(rule_datail, '$[9].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[9].r08') AS DOUBLE)) AS r089
			,if(JSON_EXTRACT(rule_datail, '$[9].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[9].r09') AS DOUBLE)) AS r099
			,if(JSON_EXTRACT(rule_datail, '$[9].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[9].r10') AS DOUBLE)) AS r109
			,if(JSON_EXTRACT(rule_datail, '$[9].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[9].r11') AS DOUBLE)) AS r119
			,if(JSON_EXTRACT(rule_datail, '$[9].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[9].r12') AS DOUBLE)) AS r129
			,JSON_EXTRACT(rule_datail, '$[9].type') AS type9
			,if(JSON_EXTRACT(rule_datail, '$[10].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[10].weight') AS DOUBLE)) AS weight10
			,if(JSON_EXTRACT(rule_datail, '$[10].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[10].r01') AS DOUBLE)) AS r0110
			,if(JSON_EXTRACT(rule_datail, '$[10].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[10].r02') AS DOUBLE)) AS r0210
			,if(JSON_EXTRACT(rule_datail, '$[10].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[10].r03') AS DOUBLE)) AS r0310
			,if(JSON_EXTRACT(rule_datail, '$[10].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[10].r04') AS DOUBLE)) AS r0410
			,if(JSON_EXTRACT(rule_datail, '$[10].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[10].r05') AS DOUBLE)) AS r0510
			,if(JSON_EXTRACT(rule_datail, '$[10].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[10].r06') AS DOUBLE)) AS r0610
			,if(JSON_EXTRACT(rule_datail, '$[10].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[10].r07') AS DOUBLE)) AS r0710
			,if(JSON_EXTRACT(rule_datail, '$[10].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[10].r08') AS DOUBLE)) AS r0810
			,if(JSON_EXTRACT(rule_datail, '$[10].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[10].r09') AS DOUBLE)) AS r0910
			,if(JSON_EXTRACT(rule_datail, '$[10].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[10].r10') AS DOUBLE)) AS r1010
			,if(JSON_EXTRACT(rule_datail, '$[10].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[10].r11') AS DOUBLE)) AS r1110
			,if(JSON_EXTRACT(rule_datail, '$[10].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[10].r12') AS DOUBLE)) AS r1210
			,JSON_EXTRACT(rule_datail, '$[10].type') AS type10
			,if(JSON_EXTRACT(rule_datail, '$[11].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[11].weight') AS DOUBLE)) AS weight11
			,if(JSON_EXTRACT(rule_datail, '$[11].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[11].r01') AS DOUBLE)) AS r0111
			,if(JSON_EXTRACT(rule_datail, '$[11].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[11].r02') AS DOUBLE)) AS r0211
			,if(JSON_EXTRACT(rule_datail, '$[11].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[11].r03') AS DOUBLE)) AS r0311
			,if(JSON_EXTRACT(rule_datail, '$[11].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[11].r04') AS DOUBLE)) AS r0411
			,if(JSON_EXTRACT(rule_datail, '$[11].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[11].r05') AS DOUBLE)) AS r0511
			,if(JSON_EXTRACT(rule_datail, '$[11].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[11].r06') AS DOUBLE)) AS r0611
			,if(JSON_EXTRACT(rule_datail, '$[11].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[11].r07') AS DOUBLE)) AS r0711
			,if(JSON_EXTRACT(rule_datail, '$[11].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[11].r08') AS DOUBLE)) AS r0811
			,if(JSON_EXTRACT(rule_datail, '$[11].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[11].r09') AS DOUBLE)) AS r0911
			,if(JSON_EXTRACT(rule_datail, '$[11].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[11].r10') AS DOUBLE)) AS r1011
			,if(JSON_EXTRACT(rule_datail, '$[11].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[11].r11') AS DOUBLE)) AS r1111
			,if(JSON_EXTRACT(rule_datail, '$[11].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[11].r12') AS DOUBLE)) AS r1211
			,JSON_EXTRACT(rule_datail, '$[11].type') AS type11
			,if(JSON_EXTRACT(rule_datail, '$[12].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[12].weight') AS DOUBLE)) AS weight12
			,if(JSON_EXTRACT(rule_datail, '$[12].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[12].r01') AS DOUBLE)) AS r0112
			,if(JSON_EXTRACT(rule_datail, '$[12].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[12].r02') AS DOUBLE)) AS r0212
			,if(JSON_EXTRACT(rule_datail, '$[12].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[12].r03') AS DOUBLE)) AS r0312
			,if(JSON_EXTRACT(rule_datail, '$[12].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[12].r04') AS DOUBLE)) AS r0412
			,if(JSON_EXTRACT(rule_datail, '$[12].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[12].r05') AS DOUBLE)) AS r0512
			,if(JSON_EXTRACT(rule_datail, '$[12].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[12].r06') AS DOUBLE)) AS r0612
			,if(JSON_EXTRACT(rule_datail, '$[12].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[12].r07') AS DOUBLE)) AS r0712
			,if(JSON_EXTRACT(rule_datail, '$[12].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[12].r08') AS DOUBLE)) AS r0812
			,if(JSON_EXTRACT(rule_datail, '$[12].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[12].r09') AS DOUBLE)) AS r0912
			,if(JSON_EXTRACT(rule_datail, '$[12].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[12].r10') AS DOUBLE)) AS r1012
			,if(JSON_EXTRACT(rule_datail, '$[12].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[12].r11') AS DOUBLE)) AS r1112
			,if(JSON_EXTRACT(rule_datail, '$[12].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[12].r12') AS DOUBLE)) AS r1212
			,JSON_EXTRACT(rule_datail, '$[12].type') AS type12
			,if(JSON_EXTRACT(rule_datail, '$[13].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[13].weight') AS DOUBLE)) AS weight13
			,if(JSON_EXTRACT(rule_datail, '$[13].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[13].r01') AS DOUBLE)) AS r0113
			,if(JSON_EXTRACT(rule_datail, '$[13].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[13].r02') AS DOUBLE)) AS r0213
			,if(JSON_EXTRACT(rule_datail, '$[13].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[13].r03') AS DOUBLE)) AS r0313
			,if(JSON_EXTRACT(rule_datail, '$[13].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[13].r04') AS DOUBLE)) AS r0413
			,if(JSON_EXTRACT(rule_datail, '$[13].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[13].r05') AS DOUBLE)) AS r0513
			,if(JSON_EXTRACT(rule_datail, '$[13].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[13].r06') AS DOUBLE)) AS r0613
			,if(JSON_EXTRACT(rule_datail, '$[13].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[13].r07') AS DOUBLE)) AS r0713
			,if(JSON_EXTRACT(rule_datail, '$[13].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[13].r08') AS DOUBLE)) AS r0813
			,if(JSON_EXTRACT(rule_datail, '$[13].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[13].r09') AS DOUBLE)) AS r0913
			,if(JSON_EXTRACT(rule_datail, '$[13].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[13].r10') AS DOUBLE)) AS r1013
			,if(JSON_EXTRACT(rule_datail, '$[13].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[13].r11') AS DOUBLE)) AS r1113
			,if(JSON_EXTRACT(rule_datail, '$[13].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[13].r12') AS DOUBLE)) AS r1213
			,JSON_EXTRACT(rule_datail, '$[13].type') AS type13
			,if(JSON_EXTRACT(rule_datail, '$[14].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[14].weight') AS DOUBLE)) AS weight14
			,if(JSON_EXTRACT(rule_datail, '$[14].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[14].r01') AS DOUBLE)) AS r0114
			,if(JSON_EXTRACT(rule_datail, '$[14].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[14].r02') AS DOUBLE)) AS r0214
			,if(JSON_EXTRACT(rule_datail, '$[14].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[14].r03') AS DOUBLE)) AS r0314
			,if(JSON_EXTRACT(rule_datail, '$[14].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[14].r04') AS DOUBLE)) AS r0414
			,if(JSON_EXTRACT(rule_datail, '$[14].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[14].r05') AS DOUBLE)) AS r0514
			,if(JSON_EXTRACT(rule_datail, '$[14].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[14].r06') AS DOUBLE)) AS r0614
			,if(JSON_EXTRACT(rule_datail, '$[14].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[14].r07') AS DOUBLE)) AS r0714
			,if(JSON_EXTRACT(rule_datail, '$[14].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[14].r08') AS DOUBLE)) AS r0814
			,if(JSON_EXTRACT(rule_datail, '$[14].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[14].r09') AS DOUBLE)) AS r0914
			,if(JSON_EXTRACT(rule_datail, '$[14].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[14].r10') AS DOUBLE)) AS r1014
			,if(JSON_EXTRACT(rule_datail, '$[14].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[14].r11') AS DOUBLE)) AS r1114
			,if(JSON_EXTRACT(rule_datail, '$[14].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[14].r12') AS DOUBLE)) AS r1214
			,JSON_EXTRACT(rule_datail, '$[14].type') AS type14
			,if(JSON_EXTRACT(rule_datail, '$[15].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[15].weight') AS DOUBLE)) AS weight15
			,if(JSON_EXTRACT(rule_datail, '$[15].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[15].r01') AS DOUBLE)) AS r0115
			,if(JSON_EXTRACT(rule_datail, '$[15].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[15].r02') AS DOUBLE)) AS r0215
			,if(JSON_EXTRACT(rule_datail, '$[15].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[15].r03') AS DOUBLE)) AS r0315
			,if(JSON_EXTRACT(rule_datail, '$[15].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[15].r04') AS DOUBLE)) AS r0415
			,if(JSON_EXTRACT(rule_datail, '$[15].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[15].r05') AS DOUBLE)) AS r0515
			,if(JSON_EXTRACT(rule_datail, '$[15].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[15].r06') AS DOUBLE)) AS r0615
			,if(JSON_EXTRACT(rule_datail, '$[15].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[15].r07') AS DOUBLE)) AS r0715
			,if(JSON_EXTRACT(rule_datail, '$[15].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[15].r08') AS DOUBLE)) AS r0815
			,if(JSON_EXTRACT(rule_datail, '$[15].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[15].r09') AS DOUBLE)) AS r0915
			,if(JSON_EXTRACT(rule_datail, '$[15].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[15].r10') AS DOUBLE)) AS r1015
			,if(JSON_EXTRACT(rule_datail, '$[15].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[15].r11') AS DOUBLE)) AS r1115
			,if(JSON_EXTRACT(rule_datail, '$[15].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[15].r12') AS DOUBLE)) AS r1215
			,JSON_EXTRACT(rule_datail, '$[15].type') AS type15
			,if(JSON_EXTRACT(rule_datail, '$[16].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[16].weight') AS DOUBLE)) AS weight16
			,if(JSON_EXTRACT(rule_datail, '$[16].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[16].r01') AS DOUBLE)) AS r0116
			,if(JSON_EXTRACT(rule_datail, '$[16].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[16].r02') AS DOUBLE)) AS r0216
			,if(JSON_EXTRACT(rule_datail, '$[16].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[16].r03') AS DOUBLE)) AS r0316
			,if(JSON_EXTRACT(rule_datail, '$[16].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[16].r04') AS DOUBLE)) AS r0416
			,if(JSON_EXTRACT(rule_datail, '$[16].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[16].r05') AS DOUBLE)) AS r0516
			,if(JSON_EXTRACT(rule_datail, '$[16].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[16].r06') AS DOUBLE)) AS r0616
			,if(JSON_EXTRACT(rule_datail, '$[16].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[16].r07') AS DOUBLE)) AS r0716
			,if(JSON_EXTRACT(rule_datail, '$[16].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[16].r08') AS DOUBLE)) AS r0816
			,if(JSON_EXTRACT(rule_datail, '$[16].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[16].r09') AS DOUBLE)) AS r0916
			,if(JSON_EXTRACT(rule_datail, '$[16].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[16].r10') AS DOUBLE)) AS r1016
			,if(JSON_EXTRACT(rule_datail, '$[16].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[16].r11') AS DOUBLE)) AS r1116
			,if(JSON_EXTRACT(rule_datail, '$[16].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[16].r12') AS DOUBLE)) AS r1216
			,JSON_EXTRACT(rule_datail, '$[16].type') AS type16
			,if(JSON_EXTRACT(rule_datail, '$[17].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[17].weight') AS DOUBLE)) AS weight17
			,if(JSON_EXTRACT(rule_datail, '$[17].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[17].r01') AS DOUBLE)) AS r0117
			,if(JSON_EXTRACT(rule_datail, '$[17].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[17].r02') AS DOUBLE)) AS r0217
			,if(JSON_EXTRACT(rule_datail, '$[17].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[17].r03') AS DOUBLE)) AS r0317
			,if(JSON_EXTRACT(rule_datail, '$[17].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[17].r04') AS DOUBLE)) AS r0417
			,if(JSON_EXTRACT(rule_datail, '$[17].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[17].r05') AS DOUBLE)) AS r0517
			,if(JSON_EXTRACT(rule_datail, '$[17].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[17].r06') AS DOUBLE)) AS r0617
			,if(JSON_EXTRACT(rule_datail, '$[17].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[17].r07') AS DOUBLE)) AS r0717
			,if(JSON_EXTRACT(rule_datail, '$[17].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[17].r08') AS DOUBLE)) AS r0817
			,if(JSON_EXTRACT(rule_datail, '$[17].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[17].r09') AS DOUBLE)) AS r0917
			,if(JSON_EXTRACT(rule_datail, '$[17].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[17].r10') AS DOUBLE)) AS r1017
			,if(JSON_EXTRACT(rule_datail, '$[17].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[17].r11') AS DOUBLE)) AS r1117
			,if(JSON_EXTRACT(rule_datail, '$[17].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[17].r12') AS DOUBLE)) AS r1217
			,JSON_EXTRACT(rule_datail, '$[17].type') AS type17
			,if(JSON_EXTRACT(rule_datail, '$[18].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[18].weight') AS DOUBLE)) AS weight18
			,if(JSON_EXTRACT(rule_datail, '$[18].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[18].r01') AS DOUBLE)) AS r0118
			,if(JSON_EXTRACT(rule_datail, '$[18].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[18].r02') AS DOUBLE)) AS r0218
			,if(JSON_EXTRACT(rule_datail, '$[18].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[18].r03') AS DOUBLE)) AS r0318
			,if(JSON_EXTRACT(rule_datail, '$[18].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[18].r04') AS DOUBLE)) AS r0418
			,if(JSON_EXTRACT(rule_datail, '$[18].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[18].r05') AS DOUBLE)) AS r0518
			,if(JSON_EXTRACT(rule_datail, '$[18].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[18].r06') AS DOUBLE)) AS r0618
			,if(JSON_EXTRACT(rule_datail, '$[18].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[18].r07') AS DOUBLE)) AS r0718
			,if(JSON_EXTRACT(rule_datail, '$[18].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[18].r08') AS DOUBLE)) AS r0818
			,if(JSON_EXTRACT(rule_datail, '$[18].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[18].r09') AS DOUBLE)) AS r0918
			,if(JSON_EXTRACT(rule_datail, '$[18].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[18].r10') AS DOUBLE)) AS r1018
			,if(JSON_EXTRACT(rule_datail, '$[18].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[18].r11') AS DOUBLE)) AS r1118
			,if(JSON_EXTRACT(rule_datail, '$[18].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[18].r12') AS DOUBLE)) AS r1218
			,JSON_EXTRACT(rule_datail, '$[18].type') AS type18
			,if(JSON_EXTRACT(rule_datail, '$[19].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[19].weight') AS DOUBLE)) AS weight19
			,if(JSON_EXTRACT(rule_datail, '$[19].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[19].r01') AS DOUBLE)) AS r0119
			,if(JSON_EXTRACT(rule_datail, '$[19].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[19].r02') AS DOUBLE)) AS r0219
			,if(JSON_EXTRACT(rule_datail, '$[19].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[19].r03') AS DOUBLE)) AS r0319
			,if(JSON_EXTRACT(rule_datail, '$[19].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[19].r04') AS DOUBLE)) AS r0419
			,if(JSON_EXTRACT(rule_datail, '$[19].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[19].r05') AS DOUBLE)) AS r0519
			,if(JSON_EXTRACT(rule_datail, '$[19].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[19].r06') AS DOUBLE)) AS r0619
			,if(JSON_EXTRACT(rule_datail, '$[19].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[19].r07') AS DOUBLE)) AS r0719
			,if(JSON_EXTRACT(rule_datail, '$[19].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[19].r08') AS DOUBLE)) AS r0819
			,if(JSON_EXTRACT(rule_datail, '$[19].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[19].r09') AS DOUBLE)) AS r0919
			,if(JSON_EXTRACT(rule_datail, '$[19].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[19].r10') AS DOUBLE)) AS r1019
			,if(JSON_EXTRACT(rule_datail, '$[19].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[19].r11') AS DOUBLE)) AS r1119
			,if(JSON_EXTRACT(rule_datail, '$[19].type')='special',null,CAST(JSON_EXTRACT(rule_datail, '$[19].r12') AS DOUBLE)) AS r1219
			,JSON_EXTRACT(rule_datail, '$[19].type') AS type19

			-- special
			,CAST(JSON_EXTRACT(rule_datail, concat('$[',json_length(cast(ebr.rule_datail as JSON))-1,'].weight[0]')) AS DOUBLE) AS more_weight
			,CAST(JSON_EXTRACT(rule_datail, concat('$[',json_length(cast(ebr.rule_datail as JSON))-1,'].weight[1]')) AS DOUBLE) AS per_weight
			,CAST(JSON_EXTRACT(rule_datail, concat('$[',json_length(cast(ebr.rule_datail as JSON))-1,'].r01')) AS DOUBLE) AS r01add
			,CAST(JSON_EXTRACT(rule_datail, concat('$[',json_length(cast(ebr.rule_datail as JSON))-1,'].r02')) AS DOUBLE) AS r02add
			,CAST(JSON_EXTRACT(rule_datail, concat('$[',json_length(cast(ebr.rule_datail as JSON))-1,'].r03')) AS DOUBLE) AS r03add
			,CAST(JSON_EXTRACT(rule_datail, concat('$[',json_length(cast(ebr.rule_datail as JSON))-1,'].r04')) AS DOUBLE) AS r04add
			,CAST(JSON_EXTRACT(rule_datail, concat('$[',json_length(cast(ebr.rule_datail as JSON))-1,'].r05')) AS DOUBLE) AS r05add
			,CAST(JSON_EXTRACT(rule_datail, concat('$[',json_length(cast(ebr.rule_datail as JSON))-1,'].r06')) AS DOUBLE) AS r06add
			,CAST(JSON_EXTRACT(rule_datail, concat('$[',json_length(cast(ebr.rule_datail as JSON))-1,'].r07')) AS DOUBLE) AS r07add
			,CAST(JSON_EXTRACT(rule_datail, concat('$[',json_length(cast(ebr.rule_datail as JSON))-1,'].r08')) AS DOUBLE) AS r08add
			,CAST(JSON_EXTRACT(rule_datail, concat('$[',json_length(cast(ebr.rule_datail as JSON))-1,'].r09')) AS DOUBLE) AS r09add
			,CAST(JSON_EXTRACT(rule_datail, concat('$[',json_length(cast(ebr.rule_datail as JSON))-1,'].r10')) AS DOUBLE) AS r10add
			,CAST(JSON_EXTRACT(rule_datail, concat('$[',json_length(cast(ebr.rule_datail as JSON))-1,'].r11')) AS DOUBLE) AS r11add
			,CAST(JSON_EXTRACT(rule_datail, concat('$[',json_length(cast(ebr.rule_datail as JSON))-1,'].r12')) AS DOUBLE) AS r12add
			,JSON_EXTRACT(rule_datail, concat('$[',json_length(cast(ebr.rule_datail as JSON))-1,'].type')) AS type_special

		FROM wms_production.express_billing_rules 	ebr
		LEFT JOIN wms_production.express_billing_rules_ref ebrr on ebrr.express_billing_rules_id = ebr.id
		WHERE status=3  -- 启用
		AND ebr.quote_type='range'
		AND ebr.delivery_rule='region'
		and ebrr.seller_id='329'
        -- and json_length(cast(ebr.rule_datail as JSON))=21
	)

	,malaysia_calc_area_map AS (   -- 大写省与大区map zhanglibin 提供
		SELECT 'JOHOR'            as province, 'Peninsular'   as area
		UNION ALL SELECT 'MELAKA'           as province, 'Peninsular'   as area
		UNION ALL SELECT 'NEGERI SEMBILAN'  as province, 'Peninsular'   as area
		UNION ALL SELECT 'SELANGOR'         as province, 'Peninsular'   as area
		UNION ALL SELECT 'PUTRAJAYA'        as province, 'Peninsular'   as area
		UNION ALL SELECT 'KUALA LUMPUR'     as province, 'Peninsular'   as area
		UNION ALL SELECT 'PAHANG'           as province, 'Peninsular'   as area
		UNION ALL SELECT 'TERENGGANU'       as province, 'Peninsular'   as area
		UNION ALL SELECT 'KELANTAN'         as province, 'Peninsular'   as area
		UNION ALL SELECT 'PERAK'            as province, 'Peninsular'   as area
		UNION ALL SELECT 'KEDAH'            as province, 'Peninsular'   as area
		UNION ALL SELECT 'PULAU PINANG'     as province, 'Peninsular'   as area
		UNION ALL SELECT 'PERLIS'           as province, 'Peninsular'   as area
		UNION ALL SELECT 'SARAWAK'          as province, 'Sarawak'   as area
		UNION ALL SELECT 'SABAH'            as province, 'Sabah'   as area
		UNION ALL SELECT 'LABUAN'           as province, 'Sabah'   as area
		-- 临时
		UNION ALL SELECT 'PENANG'            as province, 'Peninsular'  as area   -- Pulau Pinang
		UNION ALL SELECT 'W.P. KUALA LUMPUR' as province, 'Peninsular'  as area   -- Kuala Lumpur
		UNION ALL SELECT 'WP KUALA LUMPUR'   as province, 'Peninsular'  as area   -- Kuala Lumpur
		UNION ALL SELECT 'SEMBILAN'          as province, 'Peninsular'  as area   -- Negeri Sembilan
	)

	select
		t0.计费规则
		,t0.type
		,seller_name
		,warehouse_name
		,date(lanShou_time) lanshou_date
		, express_sn express_sn
		,
			case
				when charge_weight <= weight0  then (case lower(calc_area_code) when 'r01' then r010 when 'r02' then r020 when 'r03' then r030 when 'r04' then r040 when 'r05' then r050 when 'r06' then r060 when 'r07' then r070 when 'r08' then r080 when 'r09' then r090 when 'r10' then r100 when 'r11' then r110 when 'r12' then r120 end)
				when charge_weight <= weight1  then (case lower(calc_area_code) when 'r01' then r011 when 'r02' then r021 when 'r03' then r031 when 'r04' then r041 when 'r05' then r051 when 'r06' then r061 when 'r07' then r071 when 'r08' then r081 when 'r09' then r091 when 'r10' then r101 when 'r11' then r111 when 'r12' then r121 end)
				when charge_weight <= weight2  then (case lower(calc_area_code) when 'r01' then r012 when 'r02' then r022 when 'r03' then r032 when 'r04' then r042 when 'r05' then r052 when 'r06' then r062 when 'r07' then r072 when 'r08' then r082 when 'r09' then r092 when 'r10' then r102 when 'r11' then r112 when 'r12' then r122 end)
				when charge_weight <= weight3  then (case lower(calc_area_code) when 'r01' then r013 when 'r02' then r023 when 'r03' then r033 when 'r04' then r043 when 'r05' then r053 when 'r06' then r063 when 'r07' then r073 when 'r08' then r083 when 'r09' then r093 when 'r10' then r103 when 'r11' then r113 when 'r12' then r123 end)
				when charge_weight <= weight4  then (case lower(calc_area_code) when 'r01' then r014 when 'r02' then r024 when 'r03' then r034 when 'r04' then r044 when 'r05' then r054 when 'r06' then r064 when 'r07' then r074 when 'r08' then r084 when 'r09' then r094 when 'r10' then r104 when 'r11' then r114 when 'r12' then r124 end)
				when charge_weight <= weight5  then (case lower(calc_area_code) when 'r01' then r015 when 'r02' then r025 when 'r03' then r035 when 'r04' then r045 when 'r05' then r055 when 'r06' then r065 when 'r07' then r075 when 'r08' then r085 when 'r09' then r095 when 'r10' then r105 when 'r11' then r115 when 'r12' then r125 end)
				when charge_weight <= weight6  then (case lower(calc_area_code) when 'r01' then r016 when 'r02' then r026 when 'r03' then r036 when 'r04' then r046 when 'r05' then r056 when 'r06' then r066 when 'r07' then r076 when 'r08' then r086 when 'r09' then r096 when 'r10' then r106 when 'r11' then r116 when 'r12' then r126 end)
				when charge_weight <= weight7  then (case lower(calc_area_code) when 'r01' then r017 when 'r02' then r027 when 'r03' then r037 when 'r04' then r047 when 'r05' then r057 when 'r06' then r067 when 'r07' then r077 when 'r08' then r087 when 'r09' then r097 when 'r10' then r107 when 'r11' then r117 when 'r12' then r127 end)
				when charge_weight <= weight8  then (case lower(calc_area_code) when 'r01' then r018 when 'r02' then r028 when 'r03' then r038 when 'r04' then r048 when 'r05' then r058 when 'r06' then r068 when 'r07' then r078 when 'r08' then r088 when 'r09' then r098 when 'r10' then r108 when 'r11' then r118 when 'r12' then r128 end)
				when charge_weight <= weight9  then (case lower(calc_area_code) when 'r01' then r019 when 'r02' then r029 when 'r03' then r039 when 'r04' then r049 when 'r05' then r059 when 'r06' then r069 when 'r07' then r079 when 'r08' then r089 when 'r09' then r099 when 'r10' then r109 when 'r11' then r119 when 'r12' then r129 end)
				when charge_weight <= weight10 then (case lower(calc_area_code) when 'r01' then r0110 when 'r02' then r0210 when 'r03' then r0310 when 'r04' then r0410 when 'r05' then r0510 when 'r06' then r0610 when 'r07' then r0710 when 'r08' then r0810 when 'r09' then r0910 when 'r10' then r1010 when 'r11' then r1110 when 'r12' then r1210 end)
				when charge_weight <= weight11 then (case lower(calc_area_code) when 'r01' then r0111 when 'r02' then r0211 when 'r03' then r0311 when 'r04' then r0411 when 'r05' then r0511 when 'r06' then r0611 when 'r07' then r0711 when 'r08' then r0811 when 'r09' then r0911 when 'r10' then r1011 when 'r11' then r1111 when 'r12' then r1211 end)
				when charge_weight <= weight12 then (case lower(calc_area_code) when 'r01' then r0112 when 'r02' then r0212 when 'r03' then r0312 when 'r04' then r0412 when 'r05' then r0512 when 'r06' then r0612 when 'r07' then r0712 when 'r08' then r0812 when 'r09' then r0912 when 'r10' then r1012 when 'r11' then r1112 when 'r12' then r1212 end)
				when charge_weight <= weight13 then (case lower(calc_area_code) when 'r01' then r0113 when 'r02' then r0213 when 'r03' then r0313 when 'r04' then r0413 when 'r05' then r0513 when 'r06' then r0613 when 'r07' then r0713 when 'r08' then r0813 when 'r09' then r0913 when 'r10' then r1013 when 'r11' then r1113 when 'r12' then r1213 end)
				when charge_weight <= weight14 then (case lower(calc_area_code) when 'r01' then r0114 when 'r02' then r0214 when 'r03' then r0314 when 'r04' then r0414 when 'r05' then r0514 when 'r06' then r0614 when 'r07' then r0714 when 'r08' then r0814 when 'r09' then r0914 when 'r10' then r1014 when 'r11' then r1114 when 'r12' then r1214 end)
				when charge_weight <= weight15 then (case lower(calc_area_code) when 'r01' then r0115 when 'r02' then r0215 when 'r03' then r0315 when 'r04' then r0415 when 'r05' then r0515 when 'r06' then r0615 when 'r07' then r0715 when 'r08' then r0815 when 'r09' then r0915 when 'r10' then r1015 when 'r11' then r1115 when 'r12' then r1215 end)
				when charge_weight <= weight16 then (case lower(calc_area_code) when 'r01' then r0116 when 'r02' then r0216 when 'r03' then r0316 when 'r04' then r0416 when 'r05' then r0516 when 'r06' then r0616 when 'r07' then r0716 when 'r08' then r0816 when 'r09' then r0916 when 'r10' then r1016 when 'r11' then r1116 when 'r12' then r1216 end)
				when charge_weight <= weight17 then (case lower(calc_area_code) when 'r01' then r0117 when 'r02' then r0217 when 'r03' then r0317 when 'r04' then r0417 when 'r05' then r0517 when 'r06' then r0617 when 'r07' then r0717 when 'r08' then r0817 when 'r09' then r0917 when 'r10' then r1017 when 'r11' then r1117 when 'r12' then r1217 end)
				when charge_weight <= weight18 then (case lower(calc_area_code) when 'r01' then r0118 when 'r02' then r0218 when 'r03' then r0318 when 'r04' then r0418 when 'r05' then r0518 when 'r06' then r0618 when 'r07' then r0718 when 'r08' then r0818 when 'r09' then r0918 when 'r10' then r1018 when 'r11' then r1118 when 'r12' then r1218 end)
				when charge_weight <= weight19 then (case lower(calc_area_code) when 'r01' then r0119 when 'r02' then r0219 when 'r03' then r0319 when 'r04' then r0419 when 'r05' then r0519 when 'r06' then r0619 when 'r07' then r0719 when 'r08' then r0819 when 'r09' then r0919 when 'r10' then r1019 when 'r11' then r1119 when 'r12' then r1219 end)

				-- 超过标准重量

				else (case lower(calc_area_code)
				          when 'r01' then COALESCE(r0119,r0118,r0117,r0116,r0115,r0114,r0113,r0112,r0111,r0110,r019 ,r018 ,r017 ,r016 ,r015 ,r014 ,r013 ,r012 ,r011 ,r010)
				          when 'r02' then COALESCE(r0219,r0218,r0217,r0216,r0215,r0214,r0213,r0212,r0211,r0210,r029 ,r028 ,r027 ,r026 ,r025 ,r024 ,r023 ,r022 ,r021 ,r020)
						  when 'r03' then COALESCE(r0319,r0318,r0317,r0316,r0315,r0314,r0313,r0312,r0311,r0310,r039 ,r038 ,r037 ,r036 ,r035 ,r034 ,r033 ,r032 ,r031 ,r030)
						  when 'r04' then COALESCE(r0419,r0418,r0417,r0416,r0415,r0414,r0413,r0412,r0411,r0410,r049 ,r048 ,r047 ,r046 ,r045 ,r044 ,r043 ,r042 ,r041 ,r040)
						  when 'r05' then COALESCE(r0519,r0518,r0517,r0516,r0515,r0514,r0513,r0512,r0511,r0510,r059 ,r058 ,r057 ,r056 ,r055 ,r054 ,r053 ,r052 ,r051 ,r050)
						  when 'r06' then COALESCE(r0619,r0618,r0617,r0616,r0615,r0614,r0613,r0612,r0611,r0610,r069 ,r068 ,r067 ,r066 ,r065 ,r064 ,r063 ,r062 ,r061 ,r060)
						  when 'r07' then COALESCE(r0719,r0718,r0717,r0716,r0715,r0714,r0713,r0712,r0711,r0710,r079 ,r078 ,r077 ,r076 ,r075 ,r074 ,r073 ,r072 ,r071 ,r070)
						  when 'r08' then COALESCE(r0819,r0818,r0817,r0816,r0815,r0814,r0813,r0812,r0811,r0810,r089 ,r088 ,r087 ,r086 ,r085 ,r084 ,r083 ,r082 ,r081 ,r080)
						  when 'r09' then COALESCE(r0919,r0918,r0917,r0916,r0915,r0914,r0913,r0912,r0911,r0910,r099 ,r098 ,r097 ,r096 ,r095 ,r094 ,r093 ,r092 ,r091 ,r090)
						  when 'r10' then COALESCE(r1019,r1018,r1017,r1016,r1015,r1014,r1013,r1012,r1011,r1010,r109 ,r108 ,r107 ,r106 ,r105 ,r104 ,r103 ,r102 ,r101 ,r100)
						  when 'r11' then COALESCE(r1119,r1118,r1117,r1116,r1115,r1114,r1113,r1112,r1111,r1110,r119 ,r118 ,r117 ,r116 ,r115 ,r114 ,r113 ,r112 ,r111 ,r110)
						  when 'r12' then COALESCE(r1219,r1218,r1217,r1216,r1215,r1214,r1213,r1212,r1211,r1210,r129 ,r128 ,r127 ,r126 ,r125 ,r124 ,r123 ,r122 ,r121 ,r120)
						  end)
					 +(charge_weight-more_weight)*(1/per_weight)*(case lower(calc_area_code) when 'r01' then r01add when 'r02' then r02add when 'r03' then r03add when 'r04' then r04add when 'r05' then r05add when 'r06' then r06add when 'r07' then r07add when 'r08' then r08add when 'r09' then r09add when 'r10' then r10add when 'r11' then r11add when 'r12' then r12add end)
			end as amount -- *discount_rate as amount	 -- 0612折扣算在了调整金额，为了保持一致暂不计算

	from (
		select    #按区间报价
			'区间报价-大区计费' as 计费规则
			,t1.type
			,s.name seller_name
			,w.name warehouse_name
			,t1.lanShou_time
			,t1.express_sn
			,t1.business_sn
			,case area_from_to
				 when 'Peninsular (within same city)' then  'r01'
				 when 'Peninsular - Peninsular'       then  'r02'
				 when 'Peninsular - Sarawak'          then  'r03'
				 when 'Peninsular - Sabah'            then  'r04'
				 when 'Sarawak (within same city)'    then  'r05'
				 when 'Sarawak - Sarawak'             then  'r06'
				 when 'Sarawak - Peninsular'          then  'r07'
				 when 'Sarawak - Sabah'               then  'r08'
				 when 'Sabah (within same city)'      then  'r09'
				 when 'Sabah - Sabah'                 then  'r10'
				 when 'Sabah - Peninsular'            then  'r11'
				 when 'Sabah - Sarawak'               then  'r12'
			end  calc_area_code
			,GREATEST(t1.weight, (t1.length_cm*t1.width_cm*t1.height_cm)/p.weight_volume_convert) charge_weight
			,p.*
		from price1 p
		LEFT JOIN
			(

				-- 发货单
				SELECT
					'快递费' type
					,do.seller_id
					,do.warehouse_id
					,do.delivery_sn as business_sn
					,do.lanShou_time
					,do.express_sn
					,case when upper(w.province)=upper(do.province) and upper(w.city)=upper(do.city) then concat(mf.area,' (within same city)')
                          else concat(mf.area,' - ',mt.area)
                       end as area_from_to -- from..to..
					,db.length/10 length_cm
					,db.width/10 width_cm
					,db.height/10 height_cm
					,db.weight/1000 weight
				  FROM wms_production.delivery_order do
				INNER JOIN (
				   select distinct lc.id,lc.warehouse_id
					from wms_production.logistic_company lc
					-- join usable_logistic_company ulc on lc.usable_logistic_company_id= ulc.id
					where lc.customer_name='AA0039' ) lc on do.logistic_company_id=lc.id and do.warehouse_id=lc.warehouse_id
				left join wms_production.warehouse w on do.warehouse_id=w.id
                left join malaysia_calc_area_map mf on upper(w.province) = mf.province   -- from
                left join malaysia_calc_area_map mt on upper(do.province) = mt.province  -- to
                left join wms_production.delivery_box db on db.delivery_order_id=do.id
				where left(do.lanShou_time,7) = '2025-06'
                 and do.seller_id = 329 -- LYNOVA

				) t1 on p.seller_id = t1.seller_id  -- and p.warehouse_id = t1.warehouse_id
		LEFT JOIN  wms_production.`seller` s on s.id = p.seller_id
		LEFT JOIN  wms_production.`warehouse` w on w.id = t1.warehouse_id
	) t0

# 	group by 1,2,3,4,5
# ) t
# where 1=1
# and lanshou_date between concat(left(date_sub(current_date, interval 1 month),7),'-01') and last_day(date_sub(current_date, interval 1 month))
#
# group by 1,2,3,4,5


select * from wms_production.seller where name='Sace Lady'