load("/home/cfatt/scripts/mylib.il")
load("/home/cfatt/scripts/CCSinvokeCdfCallbacks.il")
load("/home/cfatt/scripts/CCSfindAbutChain.il")
load("/home/cfatt/scripts/CCSgenCSVconstraints.il")
load("./setWSP.il")

;procedure(genAMSlayout(libName cellName refLayViewName schListFile VSRpreset @key (editCDFfile nil) (route t))
procedure(genAMSlayout()
	let((cvLay cvSch cvLay1 layViewName
		 inst instName instNameList instCellName leftMostInst rightMostInst refInstName instList instList2 refInstList sortedInstList tmpInstList
		 instY
		 net netName
		 rowYoffsetList numofRows
		 bBoxLeft bBoxLeftMin bBoxBottom bBoxRight bBoxRightMax bBoxRightMax2 bBoxRightPrev bBoxTop bBoxTopPrev bBoxCenterX
		 bBoxLeftTable bBoxRightTable bBoxTopTable bBoxBottomTable 
		 instTerms term termName sourceTerms drainTerms gateTerm centerTerm
		 instIDtable netIDtable pinIDtable 
		 ioPinTable ioPinRelPosTable rhsPinTable
		 rowInstTable rowInstOverlapTable rowSpacingTable rowTopTable rowBottomTable generatedRowInstTable instRowTable yOffsetTable
		 editCDFtable 
		 schInst schRowInstTable
		 totalNumofFingers totalNumofFingersMax totalNumofFingersTable
		 abutChainTable abutChainList
		 nwellShapeTable ptapBoxShapeTable
		 i j k num1 num2 float1 list1 list2 flag1 minX minY
		 shiftX shiftY xOffset yOffset minDelta
		 row bBox 
		 overlap center
		 centerPinList
		 pinFig pinLayer pinPurpose pinHeight pinWidth label
		 termLPP termList termPin termPinFig fig termCenterX termCenterY
		 inLine inLineList inPort outPort
		 param paramVal  
	     shapeLeft shapeRight shapeBottom shapeTop shapeCenter shape shapeInst shapeBBoxAbs
	     tapCellAssociatedInstTable tapCell tapCellInstList tapCellLibName tapCellName tapCellInstCDF tapCellList tapCellType tapPinNet
	     tapCellBottom tapCellTop tapCellLeft tapCellRight
	     fingerWidth numofFingers pcPitch
	     rowLeft rowRight rowCenter rowCenterX rowLength rowLengthMax 
	     m1pin m1pinBBoxAbs 
	     metal2shape metal2shapes m2shapeList
	     metal4shapes
	     numofFinsParam numofFinsTable
	     modgenList
	     delta deltaX
	     m1GatePin m1GatePinBottomRel m1GatePinLeftRel m1GatePinRightRel m1GatePinTopRel 
	     m1shapeList m1shapeBBoxAbs m1shapeBBoxBottom m1shapeBBoxLeft m1shapeBBoxRight m1shapeBBoxTop
	     gateTermPin gateTermPinBBox leftGateTerm leftGateTermPin leftGateTermPinBBox leftInst leftNumofFingers rightInst rightNumofFingers
	     shapeBottom1 shapeBottom2 shapeCenterX shapeCenterY shapeCenterY1 shapeCenterY2 shapeTop1 shapeTop2 
	     sourceTerm sourceTermPin sourceTermPinBBox
	     trackSpacing
	     fetPCpitchParam halfFinSpacing
	     m1pinCenterX m1pinCenterY m2wsp m2wspAbs m2shape m3shape m3shapeBeginPtY m3shapeEndPtY
	     stdViaList stdVia1 stdVia1centerX stdVia1centerY stdVia2
	     via1top
	     gatePinOffsetList
	     gatePinModificationTable
	     nwell_layer ptapBoxLayer   
	     cellAbove cellBelow     
	     gateShapeBottom gateShapeTop 
	     cbShape cbMinW cbShapeBBox
	     nfetList pfetList fetList fetInstList
	     libName cellName refLayViewName schViewName VSRpreset editCDFfile route priorityRoute priority priorityList priorityTable constraintsFile routeNets nets netsFiltered
	     fingerWidthParam numofFingersParam sourceTermMatchName drainTermMatchName gateTermMatchName finPitch finThickness
		 poly_layer polyPitch polyMinW	     
	     polyContTopParam polyContTopTrue polyContTopFalse polyContBottomParam polyContBottomTrue polyContBottomFalse
	     tapCellDef tapCellRXwidthParam tapCellRXheightParam tapCellTypeParam tapCellTypeP tapCellTypeN tapCellPCpitchParam
		 trenchSilicideBlockLayer trenchSilicideBlockMinW	     
	     ca_layer caMinExtCB caMinW cb_layer
	     metal1layer metal1minW metal1enclVia1TapCell via1layer via1size via1centerSpacing
	     metal2layer metal2minPitch metal2minW metal2enclVia1TapCell stdVia2defName 
	     metal3layer metal3minW stdVia3defName
		 metal4layer	 metal4minW
		 metal3pathCenter metal3pathLeft metal3pathRight metal3pathTop metal3pathBottom
		 metal4pathLeft metal4pathRight
	     pwrRailName gndRailName pwrRailNet gndRailNet
	     pwrGndshortMarkerList pwrGndshortMarkerList2 shortMarkerList
	     stdVia2list stdVia3list via1list
	     stdVia1def stdVia2def stdVia3def
	     stdVia1defName stdVia1minCutspacing
	     stdVia1layer2Enc stdVia2layer1Enc stdVia3layer2Enc
	     tech
	     useInternalRoute
	     ioPinFig ioPinBBox ioPinCenterX ioPinCenterY
	     bBoxCenter bBoxCenterY
	     cutRows
	     )

		load("./genAMSlayout_setup.il")	         
	    load("./common_setup.il")
	    
	    
	    ;layoutTemplate=outfile(layoutTemplateFile)
	    
		;;Extract placement info from ref layout
		printf("Extracting placement info from ref layout \"%s\"\n",refLayViewName)
		cvLay=dbOpenCellViewByType(libName cellName refLayViewName)
		instList=cvLay~>instances
		;printf("%L\n",instList)
		
		tapCellLibName=car(tapCellDef)
		tapCellName=cadr(tapCellDef)
		tapCell=dbOpenCellViewByType(tapCellLibName tapCellName "layout" "maskLayout" "r")
		unless(tapCell error("Tap cell (%s %s layout) does not exist\n",tapCellLibName,tapCellName))
		
		;;Find y-offsets of all rows
		rowYoffsetList=list()
		bBoxLeftTable=makeTable("bBoxLeftTable")
		bBoxRightTable=makeTable("bBoxRightTable")
		bBoxTopTable=makeTable("bBoxTopTable")
		bBoxBottomTable=makeTable("bBoxBottomTable")
		yOffsetTable=makeTable("yOffsetTable")
		foreach(inst instList
			bBoxLeftTable[inst]=getBBoxLeft(inst)
			bBoxRightTable[inst]=getBBoxRight(inst)
			bBoxTopTable[inst]=getBBoxTop(inst)
			bBoxBottom=getBBoxBottom(inst)
			bBoxBottomTable[inst]=bBoxBottom

			if(rexMatchp(vncapMatchName inst~>cellName) then
				yOffsetTable[inst]=bBoxBottom
			else
				yOffsetTable[inst]=cadr(inst~>xy)
			)
			when(!member(yOffsetTable[inst] rowYoffsetList)
				rowYoffsetList=append(rowYoffsetList list(yOffsetTable[inst]))
			)
		)
		numofRows=length(rowYoffsetList)
		rowYoffsetList=sort(rowYoffsetList 'lessp)
		printf("numofRows: %d\n",numofRows)
		printf("rowYoffsetList: %L\n",rowYoffsetList)
		
		;;Find all instances in each row
		rowInstTable=makeTable("rowInstTable")
		instRowTable=makeTable("instRowTable")
		for(i 1 numofRows
			rowInstTable[i]=list()
			foreach(inst instList
;; 				num1=lindex(rowYoffsetList bBoxBottomTable[inst])
				num1=lindex(rowYoffsetList yOffsetTable[inst])
				;printf("%s %d\n",instID~>name num1)
				when(num1==i
					rowInstTable[i]=append(rowInstTable[i] list(inst))
					instRowTable[inst~>name]=i
				)
				;when(inst~>cellName!=tapCellName
				;	num1=lindex(rowYoffsetList bBoxBottomTable[inst])
					;printf("%s %d\n",instID~>name num1)
				;	if(num1==i then
				;		rowInstTable[i]=append(rowInstTable[i] list(inst))
				;	)
				;)
			)
		)
		printstruct(rowInstTable)
		printstruct(instRowTable)
		
		;;Sort instances in each row in order from left to right
		for(i 1 numofRows
			tmpInstList=rowInstTable[i]
			sortedInstList=list()
			for(j 1 length(rowInstTable[i])
				;printf("i:%d\n" i)
				minX=100
				foreach(inst tmpInstList
					;printf("%s %s %L\n" inst inst~>name inst~>bBox)
					;bBoxLeft=car(car(inst~>bBox))
					;bBoxLeft=bBoxLeftTable[inst]
					;printf("%f\n" bBoxLeft)
					if(bBoxLeftTable[inst]<minX then
						minX=bBoxLeftTable[inst]
						leftMostInst=inst
					)
				)
				sortedInstList=append(sortedInstList list(leftMostInst))
				;printf("sorted:%L\n" sortedInstList)
				tmpInstList=remove(leftMostInst tmpInstList)
			)
			rowInstTable[i]=sortedInstList
		)
		
		;;Compute row spacings
		rowSpacingTable=makeTable("rowSpacingTable")
		for(i 1 (numofRows-1)
			rowSpacingTable[i]=getBBoxBottom(car(rowInstTable[i+1]))-getBBoxTop(car(rowInstTable[i]))
		)
		printstruct(rowSpacingTable)
		
		rowTopTable=makeTable("rowTopTable")
		rowBottomTable=makeTable("rowBottomTable")
		for(i 1 numofRows
			rowTopTable[i]=getBBoxTop(car(rowInstTable[i]))
			rowBottomTable[i]=getBBoxBottom(car(rowInstTable[i]))
		)
		;printstruct(rowTopTable)
		;printstruct(rowBottomTable)
		
		;;Edit schematic's extreme left/right dummy devices' no. of fingers to equalize lengths of all rows
		cvSch=dbOpenCellViewByType(libName cellName schViewName "schematic" "a")
		if(cvSch==nil then
			error("Schematic view \"%s\" of cell \"%s\" does not exist\n",schViewName,cellName)
		)
		
		fetList=list()
		fetList=append(fetList pfetList)
		fetList=append(fetList nfetList)
		schRowInstTable=makeTable("schRowInstTable")
		for(i 1 numofRows
			instList=rowInstTable[i]
			schRowInstTable[i]=list()
			foreach(inst instList
				when(member(inst~>cellName fetList)
					schInst=dbFindAnyInstByName(cvSch inst~>name)
					when(schInst
						schRowInstTable[i]=append(schRowInstTable[i] list(schInst))
					)
				)
			)
		)
		printstruct(schRowInstTable)
				
		totalNumofFingersMax=0
		totalNumofFingersTable=makeTable("totalNumofFingersTable")
		numofFinsTable=makeTable("numofFinsTable")
		foreach(row schRowInstTable
			printf("row:%d\n",row)
			instList=schRowInstTable[row]
			when(instList
				totalNumofFingers=0
				foreach(inst instList
					printf("%s\n",inst~>name)
					numofFingers=get(inst numofFingersParam)
					when(stringp(numofFingers) numofFingers=atoi(numofFingers))
					totalNumofFingers=totalNumofFingers+numofFingers
					printf("numofFingers:%d\n",numofFingers)
					
					when(!rexMatchp("DUMMY" inst~>name)
						numofFinsTable[row]=get(inst numofFinsParam)
					)
				)
				totalNumofFingersTable[row]=totalNumofFingers
				when(totalNumofFingers>totalNumofFingersMax
					totalNumofFingersMax=totalNumofFingers
				)
			)
		)
		printstruct(totalNumofFingersTable)
		printstruct(numofFinsTable)
		
		when(adjustLeftRightDummyNumofFingers
			foreach(row totalNumofFingersTable
				when(totalNumofFingersTable[row]<totalNumofFingersMax
					num1=totalNumofFingersMax-totalNumofFingersTable[row]
					unless(evenp(num1) error("Difference between no. of fingers (%d) in row %d and max no. of fingers (%d) is odd\n",totalNumofFingersTable[row],row,totalNumofFingersMax))
					;printf("%d\n",num1)
					leftMostInst=car(schRowInstTable[row])
					when(rexMatchp("DUMMY" leftMostInst~>name)
						;printf("%s\n",leftMostInst~>name)
						numofFingers=get(leftMostInst numofFingersParam)
						when(stringp(numofFingers) numofFingers=atoi(numofFingers))
						editCDFparam(leftMostInst numofFingersParam (numofFingers+num1/2))
					)
					rightMostInst=car(last(schRowInstTable[row]))
					when(rexMatchp("DUMMY" rightMostInst~>name)
						printf("%s\n",rightMostInst~>name)
						numofFingers=get(rightMostInst numofFingersParam)
						when(stringp(numofFingers) numofFingers=atoi(numofFingers))
						editCDFparam(rightMostInst numofFingersParam (numofFingers+num1/2))
					)
				)
			)
		)
		
		foreach(row numofFinsTable
			instList=schRowInstTable[row]
			foreach(inst instList
				when(rexMatchp("DUMMY" inst~>name)
					editCDFparam(inst numofFinsParam numofFinsTable[row])
				)
			)
		)
		
		foreach(inst cvSch~>instances
			when(rexMatchp(vncapMatchName inst~>cellName)
				printf("vncap:%s\n",inst~>name)
				str1=get(inst vncapBotLevParamRead)
				printf("%s\n",str1)
				str1=get(inst vncapTopLevParamRead)
				printf("%s\n",str1)
			)
		)
		
		foreach(inst cvSch~>instances
			when(rexMatchp(vncapMatchName inst~>cellName)
				printf("vncap:%s\n",inst~>name)
				str1=get(inst vncapBotLevParamWrite)
				printf("%s\n",str1)
				str1=get(inst vncapTopLevParamWrite)
				printf("%s\n",str1)
			)
		)
		
		foreach(inst cvSch~>instances
			when(rexMatchp(vncapMatchName inst~>cellName)
				printf("vncap:%s\n",inst~>name)
				str1=get(inst "botlevGDS")
				printf("%s\n",str1)
				str1=get(inst "toplevGDS")
				printf("%s\n",str1)
			)
		)
		
		outPort=outfile("./invokeCDFcallbacks.log")
		poport=outPort
		woport=outPort
		errport=outPort
		;CCSinvokeCdfCallbacks(cvLay1 ?debug t ?callInitProc t ?useInstCDF t)
		CCSinvokeCdfCallbacks(cvSch ?debug t ?callInitProc t ?useInstCDF t)
		poport=stdout
		errport=stderr
		woport=stdout
		close(outPort)

		foreach(inst cvSch~>instances
			when(rexMatchp(vncapMatchName inst~>cellName)
				printf("vncap:%s\n",inst~>name)
				str1=get(inst vncapBotLevParamRead)
				printf("%s\n",str1)
				str1=get(inst vncapTopLevParamRead)
				printf("%s\n",str1)
			)
		)
		
		foreach(inst cvSch~>instances
			when(rexMatchp(vncapMatchName inst~>cellName)
				printf("vncap:%s\n",inst~>name)
				str1=get(inst "botlevGDS")
				printf("%s\n",str1)
				str1=get(inst "toplevGDS")
				printf("%s\n",str1)
			)
		)
		
		foreach(inst cvSch~>instances
			when(rexMatchp(vncapMatchName inst~>cellName)
				printf("vncap:%s\n",inst~>name)
				str1=get(inst vncapBotLevParamRead)
				putprop(inst str1 vncapBotLevParamWrite)
				printf("%s\n",str1)
				str1=get(inst vncapTopLevParamRead)
				putprop(inst str1 vncapTopLevParamWrite)
				printf("%s\n",str1)
				
				;str1=get(inst "botlevGDS")
				putprop(inst "19" "botlevGDS")
				putprop(inst "141" "toplevGDS")
			)
		)
		
		;;Find left-/right-most boundaries
		bBoxLeftMin=1000
		bBoxRightMax=0
		for(i 1 numofRows
			;printf("row %d:%L\n",i,rowInstTable[i]~>name)
			bBoxLeft=getBBoxLeft(car(rowInstTable[i]))
			if(bBoxLeft<bBoxLeftMin then
				bBoxLeftMin=bBoxLeft
			)
			bBoxRight=getBBoxRight(car(last(rowInstTable[i])))
			if(bBoxRight>bBoxRightMax then
				bBoxRightMax=bBoxRight
			)
		)
		printf("bBoxLeftMin:%f bBoxRightMax:%f\n",bBoxLeftMin,bBoxRightMax)
		
		;;Compute instance overlaps for each row
		rowInstOverlapTable=makeTable("rowInstOverlapTable")
		abutChainTable=makeTable("abutChainTable")
		;editPolyContOffsetInstList=list()
		;abuttedInstList=list()
		for(i 1 numofRows
			instList=rowInstTable[i]
			;printf("%d %L\n",i,instList~>name);
			rowInstOverlapTable[i]=list()
			bBoxRightPrev=bBoxLeftTable[car(instList)]
			;evenInst=nil
			foreach(inst instList
				;printf("%s %f\n",inst~>name,bBoxLeftTable[inst])
				overlap=bBoxRightPrev-bBoxLeftTable[inst]
				rowInstOverlapTable[i]=append(rowInstOverlapTable[i] list(overlap))
				bBoxRightPrev=bBoxRightTable[inst]
				
				;;Find abutted insts
				/*
				if((abs(overlap-0.384)/0.384)<1e-6 then ;;Abutted on the left (member of a chain)
					abuttedInstList=append(abuttedInstList list(inst~>name))
					when(evenInst
						editPolyContOffsetInstList=append(editPolyContOffsetInstList list(inst~>name))
					)
				else	 ;;Not abutted on the left (1st member of a chain or standalone)
					evenInst=nil
					list1=CCSfindAbutChain(inst)~>name
					when(list1 abutChainTable[inst~>name]=list1)
				)
				*/
				
				when(overlap<0.37
					list1=CCSfindAbutChain(inst)~>name
					when(list1 abutChainTable[inst~>name]=list1)
				)
				
				;if(evenInst then
				;	evenInst=nil
				;else	
				;	evenInst=t
				;)
			)
		)
		;printstruct(rowInstOverlapTable)
		;printf("editPolyContOffsetInstList: %L\n",editPolyContOffsetInstList)
		printstruct(abutChainTable)
		
		;;Extract IO pin layer/purpose and relative location
		rowCenterX=(bBoxLeftMin+bBoxRightMax)/2
		ioPinTable=makeTable("ioPinTable")
		rhsPinTable=makeTable("rhsPinTable")
		ioPinRelPosTable=makeTable("ioPinRelPosTable")
		centerPinList=list()
		centerPinOffsetList=list()
		termList=cvLay~>terminals
		foreach(term termList
			;printf("term:%s\n",term~>name)
			termName=term~>name
			termPin=car(term~>pins)
			termPinFig=termPin~>fig
			termLPP=termPinFig~>lpp
			pinWidth=getBBoxRight(termPinFig)-getBBoxLeft(termPinFig)
			pinHeight=getBBoxTop(termPinFig)-getBBoxBottom(termPinFig)
			;bBoxLeft=car(car(termPin~>fig~>bBox))
			;bBoxBottom=cadr(car(termPin~>fig~>bBox))
			ioPinTable[termName]=list(car(termLPP) cadr(termLPP) getBBoxLeft(termPinFig) getBBoxBottom(termPinFig) pinWidth pinHeight)
			;printf("%s %L %f %f\n",termName,termLPP,bBoxLeft,bBoxBottom)
			
			if(getBBoxLeft(termPinFig)>(bBoxRightMax-4*polyPitch) then
				rhsPinTable[termName]=getBBoxLeft(termPinFig)-bBoxRightMax
				;printf("pin on the right:%s %f\n",termName,rhsPinTable[termName])
			)
			
			instList=term~>net~>instTerms~>inst
			instList2=list()
			foreach(inst instList
				when(!member(inst instList2)
					instList2=append(instList2 list(inst))
				)
			)
			;printf("%L\n",instList2~>name)
			minY=1000
			termCenterY=cadr(centerBox(car(term~>pins)~>fig~>bBox))
			termCenterX=car(centerBox(car(term~>pins)~>fig~>bBox))
			foreach(inst instList2
				bBoxBottom=getBBoxBottom(inst)
				bBoxTop=getBBoxTop(inst)
				bBoxLeft=getBBoxLeft(inst)
				deltaX=termCenterX-bBoxLeft
				if(bBoxBottom>=termCenterY then
					delta=bBoxBottom-termCenterY
					when(delta<minY
						minY=delta
						ioPinRelPosTable[termName]=list(inst~>name "bottom" -delta deltaX)
					)
				else
					if(termCenterY>=bBoxTop then
						delta=termCenterY-bBoxTop
						when(delta<minY
							minY=delta
							ioPinRelPosTable[termName]=list(inst~>name "top" delta deltaX)
						)
					else
						if(termCenterY<=cadr(centerBox(inst~>bBox)) then
							delta=termCenterY-bBoxBottom
							when(delta<minY
								minY=delta
								ioPinRelPosTable[termName]=list(inst~>name "bottom" delta deltaX)
							)
						else
							delta=bBoxTop-termCenterY
							when(delta<minY
								minY=delta
								ioPinRelPosTable[termName]=list(inst~>name "top" -delta deltaX)
							)
						)
					)
				)
			)
			
			printf("termName:%s termCenterX:%f rowCenterX:%f\n",termName,termCenterX,rowCenterX)
			delta=termCenterX-rowCenterX
			when(abs(delta)<2*polyPitch
				centerPinList=append(centerPinList list(termName))
				centerPinOffsetList=append(centerPinOffsetList list(delta))
			)
		)
		printstruct(ioPinTable)
		printstruct(ioPinRelPosTable)
		printstruct(rhsPinTable)
		;dbClose(cvLay)
		
		pinFigTable=makeTable("pinFigTable")
		pinFigRelPosTable=makeTable("pinFigRelPosTable")
		pinFigList=setof(x cvLay~>shapes x~>purpose=="pin" && !x~>pin && x~>net && x~>net~>name!=pwrRailName && x~>net~>name!=gndRailName)
		foreach(pinFig pinFigList
			pinFigLPP=pinFig~>lpp
			pinFigWidth=getBBoxRight(pinFig)-getBBoxLeft(pinFig)
			pinFigHeight=getBBoxTop(pinFig)-getBBoxBottom(pinFig)
			pinFigTable[pinFig]=list(car(pinFigLPP) cadr(pinFigLPP) getBBoxLeft(pinFig) getBBoxBottom(pinFig) pinFigWidth pinFigHeight)
			;printf("%s %L %f %f\n",termName,termLPP,bBoxLeft,bBoxBottom)
				
			instList=pinFig~>net~>instTerms~>inst
			instList2=list()
			foreach(inst instList
				when(!member(inst instList2)
					instList2=append(instList2 list(inst))
				)
			)
			;printf("%L\n",instList2~>name)
			minY=1000
			pinFigCenterY=cadr(centerBox(pinFig~>bBox))
			pinFigCenterX=car(centerBox(pinFig~>bBox))
			foreach(inst instList2
				bBoxBottom=getBBoxBottom(inst)
				bBoxTop=getBBoxTop(inst)
				bBoxLeft=getBBoxLeft(inst)
				deltaX=pinFigCenterX-bBoxLeft
				if(bBoxBottom>=pinFigCenterY then
					delta=bBoxBottom-pinFigCenterY
					when(delta<minY
						minY=delta
						pinFigRelPosTable[pinFig]=list(inst~>name "bottom" -delta deltaX)
					)
				else
					if(pinFigCenterY>=bBoxTop then
						delta=pinFigCenterY-bBoxTop
						when(delta<minY
							minY=delta
							pinFigRelPosTable[pinFig]=list(inst~>name "top" delta deltaX)
						)
					else
						if(pinFigCenterY<=cadr(centerBox(inst~>bBox)) then
							delta=pinFigCenterY-bBoxBottom
							when(delta<minY
								minY=delta
								pinFigRelPosTable[pinFig]=list(inst~>name "bottom" delta deltaX)
							)
						else
							delta=bBoxTop-pinFigCenterY
							when(delta<minY
								minY=delta
								pinFigRelPosTable[pinFig]=list(inst~>name "top" -delta deltaX)
							)
						)
					)
				)
			)
		)
		printstruct(pinFigTable)
		printstruct(pinFigRelPosTable)
		
		;;Extract aux pwr/gnd pins (for LVS purpose)
		auxPwrGndPinTable=makeTable("auxPwrGndPinTable")
		auxPwrGndPins=setof(x cvLay~>shapes (x~>purpose=="pin" && !x~>pin && (x~>net~>name==pwrRailName || x~>net~>name==gndRailName)))
		foreach(pin auxPwrGndPins
			cellList=dbGetTrueOverlaps(cvLay pin~>bBox nil)
			when(length(cellList)==1 && car(cellList)~>cellName==tapCellName
				tapCellInst=car(cellList)
				xOffset=getBBoxLeft(pin)-car(tapCellInst~>xy)
				yOffset=getBBoxBottom(pin)-cadr(tapCellInst~>xy)
				auxPwrGndPinTable[pin]=list(tapCellInst~>name xOffset yOffset pin~>net~>name)
			)
		)
		printstruct(auxPwrGndPinTable)
		
		;;Read editCDFfile
		when(editCDFfile
			inPort=infile(editCDFfile)
			unless(inPort error("Cannot open file \"%s\"\n" editCDFfile))
			editCDFtable=makeTable("editCDFtable")
			while(gets(inLine inPort)
				inLineList=parseString(inLine ",\n")
				editCDFtable[car(inLineList)]=cdr(inLineList)
			)
			close(inPort)
		)
		
		;;Extract nwell shapes and info about the instances within them
		nwellShapeTable=makeTable("nwellShapeTable")
		tapCellAssociatedInstTable=makeTable("tapCellAssociatedInstTable")
		j=0
		foreach(shape cvLay~>shapes
			when(shape~>layerName==nwell_layer
				instList=dbGetTrueOverlaps(cvLay shape~>bBox nil)
				nwellShapeTable[j]=instList~>name
				j=j+1
				
				bBoxTop=getBBoxTop(shape)
				bBoxBottom=getBBoxBottom(shape)
				tapCellList=setof(x instList x~>cellName==tapCellName)
;; 				printf("tapCellList:%L\n",tapCellList~>name)
				foreach(tapCell tapCellList
					bBoxLeft=getBBoxLeft(tapCell)
					bBoxRight=getBBoxRight(tapCell)
					instList2=dbGetTrueOverlaps(cvLay list(list(bBoxLeft bBoxBottom) list(bBoxRight bBoxTop)) nil)
					instList2=setof(x instList2 x~>cellName!=tapCellName)
					tapCellAssociatedInstTable[tapCell~>name]=instList2~>name
;; 					printf("tap cell:%s inst:%L\n",tapCell~>name,instList2~>name)
				)
			)
		)
		;printstruct(nwellShapeTable)
		
		;;Extract PTAPBOX (user-defined) shapes and info about the instances within them
		ptapBoxShapeTable=makeTable("ptapBoxShapeTable")
		j=0
		foreach(shape cvLay~>shapes
			when(shape~>layerName==ptapBoxLayer
				instList=dbGetTrueOverlaps(cvLay shape~>bBox nil)
				ptapBoxShapeTable[j]=instList~>name
				j=j+1
				
				bBoxTop=getBBoxTop(shape)
				bBoxBottom=getBBoxBottom(shape)
				tapCellList=setof(x instList x~>cellName==tapCellName)
				;; 				printf("tapCellList:%L\n",tapCellList~>name)
				foreach(tapCell tapCellList
					bBoxLeft=getBBoxLeft(tapCell)
					bBoxRight=getBBoxRight(tapCell)
					instList2=dbGetTrueOverlaps(cvLay list(list(bBoxLeft bBoxBottom) list(bBoxRight bBoxTop)) nil)
					instList2=setof(x instList2 x~>cellName!=tapCellName)
					tapCellAssociatedInstTable[tapCell~>name]=instList2~>name
				;; 					printf("tap cell:%s inst:%L\n",tapCell~>name,instList2~>name)
				)
			)
		)
		printstruct(tapCellAssociatedInstTable)
		
		;close(layoutTemplate)		
		
		;;Gen layout from schematic
		sprintf(layViewName "layout_%s",schViewName)
		printf("Generating layout \"%s\" for schematic \"%s\"\n",layViewName,schViewName)
		;cvSch=dbOpenCellViewByType(libName cellName schViewName "schematic" "r")
		;if(cvSch==nil then
		;	error("Schematic view \"%s\" of cell \"%s\" does not exist\n",schViewName,cellName)
		;)
		
		cvLay1=dbOpenCellViewByType(libName cellName layViewName "maskLayout" "w")
		lxGenFromSource(cvSch ?layLibName libName ?layCellName cellName ?layViewName layViewName ?extractAfterGenerateAll t ?initCreateBoundary nil)
		lxUpdateBinding(cvLay1 ?schCV cvSch)
		geOpen(?lib libName ?cell cellName ?view layViewName ?mode "a")
		deInstallApp(getCurrentWindow() "VLS-EXL")
		
		;;Flatten all modgens
		modgenList=setof(x cvLay1~>figGroups x~>type=="modgen")
		mgFlattenModgens(cvLay1 modgenList)
		
		;;Associate instance name to ID
		instIDtable=makeTable("instIDtable" nil)
		foreach(inst cvLay1~>instances
			instIDtable[inst~>name]=inst
			;printf("%s %s\n",inst~>name,instTable[inst~>name])
		)
		;printstruct(instIDtable)
		
		;;Associate pin name to ID
		pinIDtable=makeTable("pinIDtable" nil)
		foreach(term cvLay1~>terminals
			pinIDtable[term~>name]=term
			;printf("%s %s\n",inst~>name,instTable[inst~>name])
		)
		;printstruct(pinIDtable)
		
		;;Associate net name to ID
		netIDtable=makeTable("netIDtable" nil)
		foreach(net cvLay1~>nets
			netIDtable[net~>name]=net
		)
		;printstruct(netIDtable)
		
		;;Modify instance parameters
		foreach(inst cvLay1~>instances
			if(member(inst~>cellName editCDFtable) then
				foreach(str1 editCDFtable[inst~>cellName]
					list1=parseString(str1 "=")
					param=car(list1)
					paramVal=cadr(list1)
					;printf("chk:%L\n",list1)
					cond(
						(paramVal=="t"	putprop(inst t param))
						(paramVal=="nil" putprop(inst nil param))
						(t putprop(inst paramVal param))
					)
				)
			)
		)
		;inst=dbFindAnyInstByName(cvLay1 "C1")
		;putprop(inst "C5" "toplev")
		;CCSinvokeCdfCallbacks(cvLay1 ?debug t ?callInitProc t ?useInstCDF t)
		foreach(inst cvLay1~>instances
			when(rexMatchp(vncapMatchName inst~>cellName)
				instName=inst~>name
				printf("vncap:%s\n",instName)
				when(rexMatchp("\\." instName)
					instName=car(parseString(instName "."))
				)
				schInst=dbFindAnyInstByName(cvSch instName)
				unless(schInst error("Schematic instance %s not found\n",instName))
				str1=get(schInst vncapBotLevParamRead)
				printf("%s\n",str1)
				putprop(inst str1 vncapBotLevParamWrite)
				str1=get(schInst vncapTopLevParamRead)
				printf("%s\n",str1)
				putprop(inst str1 vncapTopLevParamWrite)
			)
		)
		
		;;Move/create instances according to ref layout
		bBoxLeftMin=100
		bBoxRightMax=0
		tapCellInstList=list()
		generatedRowInstTable=makeTable("generatedRowInstTable")
		;tapCellInstTable=makeTable("tapCellInstTable")
		for(i 1 numofRows
;; 			fingerWidth=0
			refInstList=rowInstTable[i]
			;printf("refInstList:%L %L\n",refInstList,refInstList~>name)
			
			;;Get finger width in row
			k=0
			flag1=t
			while(flag1 && k<length(refInstList)
				flag1=!pcreMatchp("fet" nth(k refInstList)~>cellName)
				k=k+1
			)
			when(k<length(refInstList)
				fingerWidth=get(instIDtable[nth(k refInstList)~>name] fingerWidthParam)
				when(stringp(fingerWidth)
					cond(
						(pcreMatchp("n" fingerWidth)
							fingerWidth=cdfParseFloatString(fingerWidth)*1e6
						)
						(t
							fingerWidth=cdfParseFloatString(fingerWidth)
						)
					)
				)
				;printf("fingerWidth=%f\n",fingerWidth)
			)
			
			xOffset=getBBoxLeft(car(refInstList))
			if(i==1 then
				yOffset=getBBoxBottom(car(refInstList))
			else
				printf("bBoxTopPrev:%f\n",bBoxTopPrev)
				yOffset=bBoxTopPrev+rowSpacingTable[i-1]
			)
			printf("row:%d yOffset:%f\n",i,yOffset)
			;printf("%f\n",xOffset)
			k=1
			generatedRowInstTable[i]=list()
			;tapCellInstTable[i]=list()
			foreach(refInst refInstList
				refInstName=refInst~>name
				if(refInst~>cellName==tapCellName then
					inst=dbCreateInst(cvLay1 tapCell refInstName list(0 0) "R0")
					instIDtable[inst~>name]=inst
					tapCellInstList=append(tapCellInstList list(inst))
					tapCellInstCDF=cdfGetInstCDF(refInst)
					foreach(param tapCellInstCDF~>parameters~>name
						putprop(inst get(refInst param) param)
					)
					if(get(inst tapCellTypeParam)==tapCellTypeN then
						when(!ntapContEn
							putprop(inst tapCellContOff tapCellContEnParam)
						)
					else
						when(!ptapContEn
							putprop(inst tapCellContOff tapCellContEnParam)
						)
					)
				else
					inst=instIDtable[refInstName]
					putprop(inst get(refInst polyContTopParam) polyContTopParam)
					putprop(inst get(refInst polyContBottomParam) polyContBottomParam)
					when(rexMatchp(vncapMatchName refInst~>cellName)
						when(inst~>orient=="R0" && refInst~>orient=="MY"
							;dbMoveFig(inst nil list(parseFloatString(get(inst vncapWidthParam)):0 "MY"))
							dbMoveFig(inst nil list(0:0 "MY"))
						)
						when(inst~>orient=="R0" && refInst~>orient=="MX"
							;dbMoveFig(inst nil list(parseFloatString(get(inst vncapWidthParam)):0 "MX"))
							dbMoveFig(inst nil list(0:0 "MX"))
						)
					)
					;generatedRowInstTable[i]=append(generatedRowInstTable[i] list(inst))
				)
				;printf("row %d:%s %s\n",i,refInstName,instIDtable[refInstName])
				;printf("row %d:%s\n",i,refInstName)
				generatedRowInstTable[i]=append(generatedRowInstTable[i] list(inst))
				
				shiftX=-getBBoxLeft(inst)+xOffset
				shiftY=-getBBoxBottom(inst)+yOffset
				printf("chk1:%s %L\n",inst~>name,inst~>bBox)
				dbMoveFig(inst nil list(shiftX:shiftY "R0"))
				printf("chk2:%s %L\n",inst~>name,inst~>bBox)
				;shiftX=-nth((k-1) rowInstOverlapTable[i])
				;dbMoveFig(inst nil list(shiftX:0 "R0"))
				if(k<length(refInstList) then
					;xOffset=getBBoxRight(inst)
					xOffset=getBBoxRight(inst)-nth(k rowInstOverlapTable[i])
				)
				k=k+1
				
				;;Find left-most boundary
				bBoxLeft=getBBoxLeft(inst)
				if(bBoxLeft<bBoxLeftMin then
					bBoxLeftMin=bBoxLeft
				)
				
				;;Find right-most boundary
				bBoxRight=getBBoxRight(inst)
				if(bBoxRight>bBoxRightMax then
					bBoxRightMax=bBoxRight
				)
			)
		
			
			when(car(refInstList)~>cellName!=cadr(tapCellDef)
				abutChainList=list()
				instName1=car(refInstList)~>name
				printf("chk3:%s\n",instName1)
				when(member(instName1 abutChainTable~>?)
					foreach(instName2 abutChainTable[instName1]
						abutChainList=append(abutChainList list(instIDtable[instName2]))
					)
					lxChain(abutChainList getBBoxLeft(instIDtable[instName1]):getBBoxBottom(instIDtable[instName1]) ?useDeviceOrder t ?mirror nil)
				)
			)
			
			bBoxTopPrev=getBBoxTop(inst)
			printf("chk:%s %f %L\n",inst~>name,bBoxTopPrev,inst~>bBox)
			;rowSpacing=rowSpacingTable[i]
		)
		
		;;Update tap cell width to correspond to associated instances
		;printf("Updating tap cells' widths to match associated instances\n")
		foreach(tapCellName tapCellAssociatedInstTable
			instNameList=tapCellAssociatedInstTable[tapCellName]
			instList=list()
			foreach(instName instNameList
				;instList=append(instList list(instIDtable[instName]))
				when(member(instIDtable[instName]~>cellName fetList)
					instList=append(instList list(instIDtable[instName]))
				)
			)
			
			printf("instList:%L\n",instList~>name)
			
			rightMostInst=findRightMostInst(instList)
			when(member(rightMostInst~>cellName fetList)
				numofFingers=get(rightMostInst numofFingersParam)
				when(stringp(numofFingers) numofFingers=atoi(numofFingers))
				pcPitch=get(rightMostInst fetPCpitchParam2)
				when(stringp(pcPitch) pcPitch=cdfParseFloatString(pcPitch)*1e6)
				float1=car(rightMostInst~>xy)+numofFingers*pcPitch
			)
			;when(rexMatchp(vncapMatchName rightMostInst~>cellName)
			;	float1=getBBoxRight(rightMostInst)
			;)
			
			leftMostInst=findLeftMostInst(instList)
			when(member(leftMostInst~>cellName fetList)
				float2=car(leftMostInst~>xy)-pcPitch
			)
			;when(rexMatchp(vncapMatchName leftMostInst~>cellName)
			;	float2=getBBoxLeft(leftMostInst)
			;)
			
			;float1=car(rightMostInst~>xy)+numofFingers*pcPitch-(car(leftMostInst~>xy)-pcPitch)
			float1=float1-float2
			float1=float1-float(mod(int(float1*1000) int(polyPitch*1000)))/1000
			tapCell=instIDtable[tapCellName]
			putprop(tapCell float1 tapCellRXwidthParam)
			;printf("%s %f %f\n",tapCellName,bBoxLeftMin,bBoxRightMax)
		)
		
		;;Find longest row
		rowLengthMax=0
		foreach(row generatedRowInstTable
			rowLeft=getBBoxLeft(car(generatedRowInstTable[row]))
			rowRight=getBBoxRight(car(last(generatedRowInstTable[row])))
			rowLength=rowRight-rowLeft
			printf("%d rowLeft:%f rowRight:%f\n",row,rowLeft,rowRight)
			when(rowLength>rowLengthMax
				rowLengthMax=rowLength
			)
		)
		
		;;Center all rows
	    center=(2*bBoxLeftMin+rowLengthMax)/2
	    ;printf("bBoxLeftMin:%f rowLengthMax:%f center:%f\n",bBoxLeftMin,rowLengthMax,center)
	    bBoxLeftMin=100
	    bBoxRightMax=0
	    for(i 1 numofRows
	    		instList=generatedRowInstTable[i]
	    		rowLeft=getBBoxLeft(car(instList))
	    		rowRight=getBBoxRight(car(last(instList)))
	    		;printf("%s\n",car(last(instList))~>name)
	    		;printf("row:%d left:%f right:%f\n",i,rowLeft,rowRight)
	    		rowCenter=(rowLeft+rowRight)/2
	    		shiftX=center-rowCenter
	    		foreach(inst instList
	    			dbMoveFig(inst nil list(shiftX:0 "R0"))
	    			
	    			;;Find left-most boundary
				bBoxLeft=getBBoxLeft(inst)
				if(bBoxLeft<bBoxLeftMin then
					bBoxLeftMin=bBoxLeft
				)
				
				;;Find right-most boundary
				bBoxRight=getBBoxRight(inst)
				if(bBoxRight>bBoxRightMax then
					bBoxRightMax=bBoxRight
				)
	    		)
	    )
	    ;printf("bBoxLeftMin:%f bBoxRightMax:%f\n",bBoxLeftMin,bBoxRightMax)
	    
		;;Connect power/gnd source/drain terms to tap cells vertically
		fetInstList=list()
		for(i 1 numofRows
			instList=generatedRowInstTable[i]
			foreach(inst instList
				when(member(inst~>cellName fetList) fetInstList=append(fetInstList list(inst)))
			)
		)
		;printf("fetInstList:%L\n",fetInstList~>name)
		
		noTapCellInstList=list()
		for(i 1 numofRows
			instList=generatedRowInstTable[i]
			instList2=list()
			foreach(inst instList
				instCellName=inst~>cellName
				when(member(instCellName fetList)
					instName=inst~>name
					
					row=instRowTable[instName]
					if(row<numofRows then
						cellAbove=car(generatedRowInstTable[row+1])
					else	
						cellAbove=nil
					)
					if(row>1 then
						cellBelow=car(generatedRowInstTable[row-1])
					else	
						cellBelow=nil
					)
					
					if(member(instCellName pfetList) then
						tapCellType=tapCellTypeN
						tapPinNet=pwrRailName
					else
						tapCellType=tapCellTypeP
						tapPinNet=gndRailName
					)
					
					bBoxLeft=getBBoxLeft(inst)
					bBoxBottom=getBBoxBottom(inst)
					
					flag1=nil
					when(cellAbove
						when(cellAbove~>cellName==tapCellName && get(cellAbove tapCellTypeParam)==tapCellType
							flag1=t
							printf("%s %s\n",instName,cellAbove~>name)
							sourceTerms=setof(term inst~>instTerms rexMatchp(sourceTermMatchName term~>name))
                             drainTerms=setof(term inst~>instTerms rexMatchp(drainTermMatchName term~>name))
                             termList=setof(term sourceTerms rexMatchp(tapPinNet term~>net~>name))
                             termList=append(termList setof(term drainTerms rexMatchp(tapPinNet term~>net~>name)))
                             printf("%L\n",termList~>net~>name)
                             foreach(term termList
                             	foreach(pin term~>term~>pins
                             		foreach(fig pin~>figs
                             			when(fig~>layerName==metal1layer
                             				bBox=dbTransformBBox(fig~>bBox dbGetInstTransform(list(inst)))
                             				;printf("%s %L\n",term~>net~>name,bBox)
                             				shapeLeft=car(car(bBox))
                             				shapeRight=car(cadr(bBox))
                             				shapeBottom=cadr(car(bBox))
                             				if(parseFloatString(get(inst fetPCpitchParam2))>polyPitch then
                             					shapeTop=getBBoxTop(inst)
                             					dbCreateRect(cvLay1 list(metal1layer "drawing") list(shapeLeft:shapeBottom shapeRight:shapeTop))
                             					
                             					via1top=shapeTop-stdVia1layer1Enc
                             					via1bottom=via1top-via1size
                             					dbCreateRect(cvLay1 list(via1layer "drawing") list(shapeLeft:via1bottom shapeRight:via1top))
                             					
                             					via1top=via1bottom-minVia1edgeSpacing
                             					via1bottom=via1top-via1size
                             					dbCreateRect(cvLay1 list(via1layer "drawing") list(shapeLeft:via1bottom shapeRight:via1top))
                             					
                             					metal2bottom=via1bottom-stdVia1layer2Enc
                             					metal2top=cadr(cellAbove~>xy)
                             					dbCreateRect(cvLay1 list(metal2layer "drawing") list(shapeLeft:metal2bottom shapeRight:metal2top))
                             				else
	                             				shapeTop=cadr(cellAbove~>xy)+0.02
	                             				dbCreateRect(cvLay1 list(metal1layer "drawing") list(shapeLeft:shapeBottom shapeRight:shapeTop))
	                             			)
                             			)
                             		)
                             	)
							)
						)
					)
					
					flag2=nil
					when(cellBelow
						when(cellBelow~>cellName==tapCellName && get(cellBelow tapCellTypeParam)==tapCellType
							flag2=t
							;printf("%s %s\n",instName,cellBelow~>name)
							sourceTerms=setof(term inst~>instTerms rexMatchp(sourceTermMatchName term~>name))
							drainTerms=setof(term inst~>instTerms rexMatchp(drainTermMatchName term~>name))
							termList=setof(term sourceTerms rexMatchp(tapPinNet term~>net~>name))
							termList=append(termList setof(term drainTerms rexMatchp(tapPinNet term~>net~>name)))
                            ;printf("%L\n",termList~>net~>name)
                             foreach(term termList
                             	foreach(pin term~>term~>pins
                             		foreach(fig pin~>figs
                             			when(fig~>layerName=="M1"
                             				bBox=dbTransformBBox(fig~>bBox dbGetInstTransform(list(inst)))
                             				;printf("%s %L\n",term~>net~>name,bBox)
                             				shapeLeft=car(car(bBox))
                             				shapeRight=car(cadr(bBox))
                             				shapeTop=cadr(car(bBox))
                             				shapeBottom=cadr(cellBelow~>xy)
                             				dbCreateRect(cvLay1 list(metal1layer "drawing") list(shapeLeft:shapeBottom shapeRight:shapeTop))
                             			)
                             		)
                             	)
							)
						)
					)
					
					when(!flag1 && !flag2 
						instList2=append(instList2 list(inst))
						noTapCellInstList=append(noTapCellInstList list(inst))
					)
				)
			)
			
			when(instList2
				printf("instList2:%L\n",instList2~>name)
				bBoxLeftMost=1000
				bBoxRightMost=-1000
				;prevShapeRight=-1000
				;dualMetal2trunks=nil
				via1list=list()
				prevShapeLeft=1000
				foreach(inst instList2
					gateTerm=car(setof(x inst~>instTerms rexMatchp(gateTermMatchName x~>name)))
					fig=car(gateTerm~>term~>pins)~>fig
					gateTermBBox=dbTransformBBox(fig~>bBox dbGetInstTransform(list(inst)))
					gateTermBottom=bBoxBottom(gateTermBBox)
					gateTermTop=bBoxTop(gateTermBBox)
					gateTermLeft=bBoxLeft(gateTermBBox)
					gateTermRight=bBoxRight(gateTermBBox)
					firstSourceTerm=car(setof(x inst~>instTerms rexMatchp(sourceTermMatchName x~>name)))
					firstDrainTerm=car(setof(x inst~>instTerms rexMatchp(drainTermMatchName x~>name)))
					extendCA=nil
					when(rexMatchp("DUMMY" inst~>name) && 
						 firstSourceTerm~>net==firstDrainTerm~>net && 
						 (firstSourceTerm~>net~>name==pwrRailName || firstDrainTerm~>net~>name==gndRailName) &&
						 parseFloatString(get(inst numofFingersParam))>1
						extendCA=t
						printf("extendCA %s\n",inst~>name)
						cbShape=cadr(car(dbGetTrueOverlaps(cvLay1 gateTermBBox cb_layer 0:1)))
						cbShapeBBox=dbTransformBBox(cbShape~>bBox dbGetInstTransform(list(inst)))
						shapeLeft=bBoxLeft(cbShapeBBox)-cbExtOverlapCA
						shapeRight=bBoxRight(cbShapeBBox)+cbExtOverlapCA
						shapeBottom=bBoxBottom(cbShapeBBox)
						shapeTop=bBoxTop(cbShapeBBox)
						dbCreateRect(cvLay1 list(cb_layer "drawing") list(shapeLeft:shapeBottom shapeRight:shapeTop))
					)
					
					foreach(instTerm setof(x inst~>instTerms ((rexMatchp(sourceTermMatchName x~>name) || rexMatchp(drainTermMatchName x~>name)) && (x~>net~>name==pwrRailName || x~>net~>name==gndRailName)))
						fig=car(instTerm~>term~>pins)~>fig
						bBox=dbTransformBBox(fig~>bBox dbGetInstTransform(list(inst)))
						bBoxLeft=bBoxLeft(bBox)
						printf("bBoxLeft:%f\n",bBoxLeft)
						bBoxRight=bBoxRight(bBox)
						when(bBoxLeft<bBoxLeftMost bBoxLeftMost=bBoxLeft)
						when(bBoxRight>bBoxRightMost bBoxRightMost=bBoxRight)
						bBoxBottom=bBoxBottom(bBox)
						bBoxTop=bBoxTop(bBox)
						
						;;Extend CA to gate term (for dummy devs only)
						when(extendCA
							row=instRowTable[inst~>name]
							leftInst=nth(lindex(generatedRowInstTable[row]~>name inst~>name)-2 generatedRowInstTable[row])
							flag1=t
							/*
							when(leftInst
								foreach(instTerm2 setof(x leftInst~>instTerms (rexMatchp(sourceTermMatchName x~>name) || rexMatchp(drainTermMatchName x~>name)))
									fig=car(instTerm2~>term~>pins)~>fig
									bBox2=dbTransformBBox(fig~>bBox dbGetInstTransform(list(leftInst)))
									when(abs(bBoxLeft(bBox2)-bBoxLeft)<0.001 flag1=nil)
								)
							)
							*/
							when(flag1
								instTermCenterX=car(centerBox(bBox))
								shapeLeft=instTermCenterX-caMinW/2
								shapeRight=shapeLeft+caMinW
								if(bBoxBottom>gateTermBottom then
									shapeBottom=gateTermBottom-caMinExtCB
									shapeTop=cadr(inst~>xy)
								else
									shapeTop=gateTermTop+caMinExtCB
									shapeBottom=cadr(inst~>xy)
								)
								dbCreateRect(cvLay1 list(ca_layer "drawing") list(shapeLeft:shapeBottom shapeRight:shapeTop))
								
								
							)
						)
						
						;;Create via1's
						;shapeBottom=cadr(car(instList2)~>xy)-(finPitch-finThickness)/2+metal2minPitch+metal2minPitchExtra
						sourceTermBBox=car(car(setof(x car(instList2)~>instTerms rexMatchp(sourceTermMatchName x~>name)))~>term~>pins)~>fig~>bBox
						printf("sourceTermBBox:%L\n",sourceTermBBox)
						sourceTermBBoxBottom=bBoxBottom(sourceTermBBox)
						sourceTermBBoxTop=bBoxTop(sourceTermBBox)				
						shapeBottom=cadr(car(instList2)~>xy)+sourceTermBBoxBottom+stdVia1layer1Enc
					
						shapeLeft=bBoxLeft
						shapeRight=bBoxRight
						;when(shapeLeft-prevShapeRight<stdVia1minCutspacing 
						;	shapeBottom=shapeBottom+metal2minPitch+metal2minPitchExtra
						;	dualMetal2trunks=t
						;)
						shapeTop=shapeBottom+metal2minW
						via1=dbCreateRect(cvLay1 list(via1layer "drawing") list(shapeLeft:shapeBottom shapeRight:shapeTop))
						via1list=append(via1list list(via1))
						;when(int(shapeLeft*1000)!=int(prevShapeLeft*1000)
						;	printf("via1 shapeleft:%f\n",shapeLeft)
						;	via1=dbCreateRect(cvLay1 list(via1layer "drawing") list(shapeLeft:shapeBottom shapeRight:shapeTop))
						;	via1list=append(via1list list(via1))
						;)
						;prevShapeLeft=shapeLeft
						;prevShapeRight=shapeRight
					)
				)
				printf("leftmost:%f rightmost:%f\n",bBoxLeftMost,bBoxRightMost)
				
				via1listSorted=list()
				num1=length(via1list)
				for(i 0 (num1-1)
					via1bBoxLeftMost=1000
					m=0
					foreach(via1 via1list
						bBoxLeft=getBBoxLeft(via1)
						when(bBoxLeft<via1bBoxLeftMost
							via1bBoxLeftMost=bBoxLeft
							via1leftMost=via1
							j=m
						)
						m=m+1
					)
					via1listSorted=append(via1listSorted list(via1leftMost))
					via1list2=list()
					for(k 0 (length(via1list)-1)
						when(k!=j via1list2=append(via1list2 list(nth(k via1list))))
					)
					via1list=via1list2
				)
				printf("via1listSorted:%L\n",via1listSorted~>bBox)
				
				prevShapeRight=-1000
				dualMetal2trunks=nil
				prevShapeLeft=1000
				foreach(via1 via1listSorted
					shapeBottom=cadr(car(instList2)~>xy)-(finPitch-finThickness)/2+metal2minPitch+metal2minPitchExtra
					shapeLeft=getBBoxLeft(via1)
					shapeRight=getBBoxRight(via1)
					if(shapeLeft-prevShapeRight<stdVia1minCutspacing then
						;dbMoveFig(via1 nil list(0:(metal2minPitch+metal2minPitchExtra) "R0"))
						dbDeleteObject(via1)
						dualMetal2trunks=t
					else
						prevShapeRight=shapeRight
					)
					when(abs(prevShapeLeft-shapeLeft)<0.001 dbDeleteObject(via1))
					prevShapeLeft=shapeLeft
				)
				
				when(bBoxLeftMost!=1000
					;;Create metal2 trunk
					;shapeBottom=cadr(car(instList2)~>xy)-(finPitch-finThickness)/2+metal2minPitch+metal2minPitchExtra
					sourceTermBBox=car(car(setof(x car(instList2)~>instTerms rexMatchp(sourceTermMatchName x~>name)))~>term~>pins)~>fig~>bBox
					printf("sourceTermBBox:%L\n",sourceTermBBox)
					sourceTermBBoxBottom=bBoxBottom(sourceTermBBox)
					sourceTermBBoxTop=bBoxTop(sourceTermBBox)				
					shapeBottom=cadr(car(instList2)~>xy)+sourceTermBBoxBottom+stdVia1layer1Enc
					printf("chk shapeBottom:%f\n",shapeBottom)
					shapeTop=shapeBottom+metal2minW
					shapeLeft=bBoxLeftMost-stdVia1layer2Enc
					shapeRight=bBoxRightMost+stdVia1layer2Enc
					dbCreateRect(cvLay1 list(metal2layer "drawing") list(shapeLeft:shapeBottom shapeRight:shapeTop))
					
					;when(dualMetal2trunks
					;	shapeBottom2=shapeBottom+metal2minPitch+metal2minPitchExtra
					;	shapeTop2=shapeBottom2+metal2minW
					;	dbCreateRect(cvLay1 list(metal2layer "drawing") list(shapeLeft:shapeBottom2 shapeRight:shapeTop2))
					;)
				
					foreach(tapCell tapCellAssociatedInstTable~>?
						printf("%s %L\n",tapCell,tapCellAssociatedInstTable[tapCell])
						when(member(car(instList2)~>name tapCellAssociatedInstTable[tapCell])
							associatedTapCellName=tapCell
						)
					)
					printf("tapcell:%s\n",associatedTapCellName)
					associatedTapCell=dbFindAnyInstByName(cvLay1 associatedTapCellName)
					
					;;Create metal3 trunks and via2's
					tapCellBottom=cadr(associatedTapCell~>xy)
					tapCellTop=tapCellBottom+parseFloatString(get(associatedTapCell tapCellRXheightParam))
					tapCellCenterY=(tapCellBottom+tapCellTop)/2

					if(shapeBottom>tapCellBottom then
						shapeBottom=tapCellBottom-stdVia2layer2Enc
						shapeTop=shapeTop+stdVia2layer2Enc
					else
						shapeBottom=shapeBottom-stdVia2layer2Enc
						shapeTop=tapCellTop+stdVia2layer2Enc
					)
					
					shapeCenterX=bBoxLeftMost+metal3minW/2
					shapeCenterX=snap(shapeCenterX trackSpacing[metal3layer] ?direction "right")
					pwrGndNetName=pwrRailName
					when(get(associatedTapCell tapCellTypeParam)==tapCellTypeP pwrGndNetName=gndRailName)
					pwrGndNet=dbFindNetByName(cvLay1 pwrGndNetName)
					shapeCenterX=findTrack(cvLay1 shapeCenterX (shapeBottom-lineEndSpacing[metal3layer]) (shapeTop+lineEndSpacing[metal3layer]) "vertical" trackSpacing[metal3layer] trackWidth[metal3layer] metal3layer pwrGndNet "both")		
					shapeLeft=shapeCenterX-metal3minW/2
					shapeRight=shapeLeft+metal3minW
					
					flag1=nil
					while(shapeRight<bBoxRightMost
						metal3shapeTop=shapeTop
						;when(flag1 metal3shapeTop=shapeTop2+stdVia2layer2Enc)
						dbCreateRect(cvLay1 list(metal3layer "drawing") list(shapeLeft:shapeBottom shapeRight:metal3shapeTop))
						
						if(shapeBottom>tapCellBottom then
							via2top=metal3shapeTop-stdVia2layer2Enc
							via2bottom=via2top-via2size
						else
							via2bottom=shapeBottom+stdVia2layer2Enc
							via2top=via2bottom+via2size
						)
						dbCreateRect(cvLay1 list(via2layer "drawing") list(shapeLeft:via2bottom shapeRight:via2top))
						
						via2CenterY=tapCellCenterY
						via2top=via2CenterY+via2size/2
						via2bottom=via2CenterY-via2size/2
						dbCreateRect(cvLay1 list(via2layer "drawing") list(shapeLeft:via2bottom shapeRight:via2top))
						
						via2CenterY=tapCellCenterY+via2centerSpacing
						via2top=via2CenterY+via2size/2
						via2bottom=via2CenterY-via2size/2
						dbCreateRect(cvLay1 list(via2layer "drawing") list(shapeLeft:via2bottom shapeRight:via2top))
						
						via2CenterY=tapCellCenterY-via2centerSpacing
						via2top=via2CenterY+via2size/2
						via2bottom=via2CenterY-via2size/2
						dbCreateRect(cvLay1 list(via2layer "drawing") list(shapeLeft:via2bottom shapeRight:via2top))
						
						;shapeLeft=shapeLeft+2*meshSpacing[metal3layer]
						shapeLeft=shapeLeft+meshSpacing[metal3layer]
						shapeRight=shapeLeft+metal3minW
						
						flag1=!flag1
					)
				)
			)
		)
		
		;;Place metal2 and via1 over tap cells (required for passing LVS; should be disabled for hierarchical layout for proper vertical abutment)
		when(metal2overTapCell
			foreach(inst tapCellInstList
				;;Place via1's
				pcPitch=parseFloatString(get(inst tapCellPCpitchParam))
				;when(stringp(pcPitch) pcPitch=cdfParseFloatString(pcPitch)*1e6)
				tapCellLeft=car(inst~>xy)
				tapCellRight=tapCellLeft+parseFloatString(get(inst tapCellRXwidthParam))
				tapCellBottom=cadr(inst~>xy)
				tapCellTop=tapCellBottom+parseFloatString(get(inst tapCellRXheightParam))
				shapeCenterX=tapCellLeft+pcPitch/2
				shapeCenterY=(tapCellBottom+tapCellTop)/2
				flag1=t
				while(shapeCenterX<tapCellRight
					if(flag1 then ;;Odd cols
						shapeLeft=shapeCenterX-via1size/2
						shapeRight=shapeCenterX+via1size/2
						shapeBottom=shapeCenterY-via1size/2
						shapeTop=shapeCenterY+via1size/2
						dbCreateRect(cvLay1 list(via1layer "drawing") list(shapeLeft:shapeBottom shapeRight:shapeTop))
						shapeBottom=shapeCenterY+via1centerSpacing-via1size/2
						shapeTop=shapeBottom+via1size
						via1top=shapeTop
						dbCreateRect(cvLay1 list(via1layer "drawing") list(shapeLeft:shapeBottom shapeRight:shapeTop))
						shapeBottom=tapCellBottom
						shapeTop=via1top+metal1enclVia1TapCell
						dbCreateRect(cvLay1 list(metal1layer "drawing") list(shapeLeft:shapeBottom shapeRight:shapeTop))
						shapeCenterX=shapeCenterX+pcPitch
						flag1=nil
					else ;;Even cols
						shapeLeft=shapeCenterX-via1size/2
						shapeRight=shapeCenterX+via1size/2
						shapeCenterY1=shapeCenterY+via1centerSpacing/2
						shapeCenterY2=shapeCenterY-via1centerSpacing/2
						shapeBottom1=shapeCenterY1-via1size/2
						shapeBottom2=shapeCenterY2-via1size/2
						shapeTop1=shapeCenterY1+via1size/2
						shapeTop2=shapeCenterY2+via1size/2
						dbCreateRect(cvLay1 list(via1layer "drawing") list(shapeLeft:shapeBottom1 shapeRight:shapeTop1))
						dbCreateRect(cvLay1 list(via1layer "drawing") list(shapeLeft:shapeBottom2 shapeRight:shapeTop2))
						shapeCenterX=shapeCenterX+pcPitch
						flag1=t
					)
				)
				
				;;Place metal2
				shapeTop=via1top+metal2enclVia1TapCell
				shapeBottom=tapCellBottom
				;shapeBottom=tapCellBottom-(shapeTop-tapCellTop)
				dbCreateRect(cvLay1 list(metal2layer "drawing") list(tapCellLeft:shapeBottom tapCellRight:shapeTop))
			)
		)
		
		;;Connect inst terms to pwr/gnd (excluding source/drain terms)
		lceExtract(cvLay1)
		tech=techGetTechFile(cvLay1)
		stdVia1def=techFindViaDefByName(tech stdVia1defName)
		stdVia2def=techFindViaDefByName(tech stdVia2defName)
		stdVia3def=techFindViaDefByName(tech stdVia3defName)
		for(i 1 numofRows
			instList=generatedRowInstTable[i]
			foreach(inst instList
				foreach(tapCell tapCellAssociatedInstTable~>?
					when(member(inst~>name tapCellAssociatedInstTable[tapCell])
						associatedTapCellName=tapCell
					)
				)
				printf("inst:%s tapcell:%s\n",inst~>name,associatedTapCellName)
				associatedTapCell=dbFindAnyInstByName(cvLay1 associatedTapCellName)
				associatedTapCellBottom=cadr(associatedTapCell~>xy)
				associatedTapCellTop=associatedTapCellBottom+tapCellRXheight
						
				instTerms=inst~>instTerms
				foreach(instTerm instTerms
					when(!rexMatchp(sourceTermMatchName instTerm~>name) && !rexMatchp(drainTermMatchName instTerm~>name) && !rexMatchp(bulkTermMatchName instTerm~>name) &&
						 !rexMatchp(vncapRefTermMatchName instTerm~>name)	 &&					 
						 (instTerm~>net~>name==pwrRailName || instTerm~>net~>name==gndRailName) &&
						 !rexMatchp("DUMMY" inst~>name)
						printf("%s %s\n",inst~>name,instTerm~>name)
						fig=car(instTerm~>term~>pins)~>fig
						bBox=dbTransformBBox(fig~>bBox dbGetInstTransform(list(inst)))
						instTermBottom=bBoxBottom(bBox)

						when(instTerm~>name==gateTermMatchName
							cutRows=int(((bBoxRight(bBox)-bBoxLeft(bBox))-2*stdVia1layer2Enc)/(stdVia1minCutspacing+via1size))+1
							dbCreateVia(cvLay1 stdVia1def centerBox(bBox) "R90" list(list("cutRows" cutRows) list("cutSpacing" list(stdVia1minCutspacing stdVia1minCutspacing))))
						)
						
						tapCellBottom=associatedTapCellBottom
						tapCellTop=associatedTapCellTop
						defaultTapCell=t
						when((instTerm~>net~>name==gndRailName && get(associatedTapCell tapCellTypeParam)==tapCellTypeN) ||
							 (instTerm~>net~>name==pwrRailName && get(associatedTapCell tapCellTypeParam)==tapCellTypeP)
							defaultTapCell=nil
							printf("incorrect defaultTapCell:%s\n",inst~>name)
							minDelta=100
							foreach(tapCell tapCellInstList
								when((instTerm~>net~>name==gndRailName && get(tapCell tapCellTypeParam)==tapCellTypeP) ||
							 		 (instTerm~>net~>name==pwrRailName && get(tapCell tapCellTypeParam)==tapCellTypeN)
							 		delta=abs(instTermBottom-cadr(tapCell~>xy))
							 		when(delta<minDelta
							 			minDelta=delta
							 			newAssociatedTapCell=tapCell
							 		)
								)
							)
							printf("changing tapcell to %s\n",newAssociatedTapCell~>name)
							tapCellBottom=cadr(newAssociatedTapCell~>xy)
							tapCellTop=tapCellBottom+tapCellRXheight
						)
						
						if(bBoxBottom(bBox)>tapCellBottom then
							metal3pathTop=bBoxTop(bBox)
							when(instTerm~>name==gateTermMatchName
								metal3pathTop=metal3pathTop+stdVia2layer2Enc
							)
							metal3pathBottom=tapCellBottom-stdVia2layer2Enc
						else
							metal3pathTop=tapCellTop+stdVia2layer2Enc
							metal3pathBottom=bBoxBottom(bBox)
							when(instTerm~>name==gateTermMatchName
								metal3pathBottom=metal3pathBottom-stdVia2layer2Enc
							)
						)
						
						metal3pathCenterX=car(centerBox(bBox))
						metal3pathCenterX=snap(metal3pathCenterX trackSpacing[metal3layer] ?direction "left")
						metal3pathCenterX=findTrack(cvLay1 metal3pathCenterX metal3pathBottom metal3pathTop "vertical" trackSpacing[metal3layer] trackWidth[metal3layer] metal3layer instTerm~>net "both")		
						shapeLeft=metal3pathCenterX-metal3minW/2
						metal3pathCenterXfirst=metal3pathCenterX
						list1=list()
						while(shapeLeft>bBoxLeft(bBox)
							list1=append(list1 list(metal3pathCenterX))
							metal3pathCenterX=metal3pathCenterX-meshSpacing[metal3layer]
							shapeLeft=metal3pathCenterX-metal3minW/2
						)
						metal3pathCenterX=metal3pathCenterXfirst+meshSpacing[metal3layer]
						shapeRight=metal3pathCenterX+metal3minW/2
						while(shapeRight<bBoxRight(bBox)
							list1=append(list1 list(metal3pathCenterX))
							metal3pathCenterX=metal3pathCenterX+meshSpacing[metal3layer]
							shapeRight=metal3pathCenterX+metal3minW/2
						)
						
						foreach(metal3pathCenterX list1
							shapeLeft=metal3pathCenterX-metal3minW/2
							shapeRight=metal3pathCenterX+metal3minW/2
							dbCreateRect(cvLay1 list(metal3layer "drawing") list(shapeLeft:metal3pathBottom shapeRight:metal3pathTop))
							
							when(instTerm~>name==gateTermMatchName
								dbCreateVia(cvLay1 stdVia2def list(metal3pathCenterX cadr(centerBox(bBox))) "R0" list(list("layer1Enc" list(stdVia2layer1Enc 0))))
							)
							
							;via2CenterY=cadr(centerBox(nearestM2shape~>bBox))
							via2CenterY=(tapCellTop+tapCellBottom)/2
							via2top=via2CenterY+via2size/2
							via2bottom=via2CenterY-via2size/2
							dbCreateRect(cvLay1 list(via2layer "drawing") list(shapeLeft:via2bottom shapeRight:via2top))
							
							;when((bBoxTop(nearestM2shape~>bBox)-bBoxBottom(nearestM2shape~>bBox))>metal2minW+0.001 )
							via2CenterY=via2CenterY+via2centerSpacing
							via2top=via2CenterY+via2size/2
							via2bottom=via2CenterY-via2size/2
							dbCreateRect(cvLay1 list(via2layer "drawing") list(shapeLeft:via2bottom shapeRight:via2top))
							
							via2CenterY=via2CenterY-2*via2centerSpacing
							via2top=via2CenterY+via2size/2
							via2bottom=via2CenterY-via2size/2
							dbCreateRect(cvLay1 list(via2layer "drawing") list(shapeLeft:via2bottom shapeRight:via2top))
						)
						lceExtract(cvLay1)
					)
				)
			)
		)
		
		;;Connect gates of dummy cells (multi-finger)
		for(i 1 numofRows
			instList=generatedRowInstTable[i]
			k=0
			foreach(inst instList
				instTerms=inst~>instTerms
				list1=sort(instTerms~>net~>name 'alphalessp)
				when(rexMatchp("DUMMY" inst~>name)
					printf("dummy cell:%s\n",inst~>name)
					numofFingers=get(inst numofFingersParam)
					when(stringp(numofFingers) numofFingers=atoi(numofFingers))
					if(numofFingers>1 then
						termList=setof(term inst~>instTerms rexMatchp(sourceTermMatchName term~>name))
						termList=append(termList setof(term inst~>instTerms rexMatchp(drainTermMatchName term~>name)))
						bBoxCenterX=car(centerBox(inst~>bBox))
						;printf("bBoxCenterX:%f\n",bBoxCenterX)
						minDelta=100
						for(j 0 length(termList)-1
							term=nth(j termList)
							when(term~>net~>name==pwrRailName || term~>net~>name==gndRailName
								fig=car(car(term~>term~>pins)~>figs)
								bBox=dbTransformBBox(fig~>bBox dbGetInstTransform(list(inst)))
	             				shapeLeft=car(car(bBox))
	             				shapeRight=car(cadr(bBox))
	             				shapeCenter=(shapeLeft+shapeRight)/2
								when(abs(shapeCenter-bBoxCenterX)<minDelta
									minDelta=abs(shapeCenter-bBoxCenterX)
									centerTerm=j
								)
							)
						)
						;printf("centerTerm:%d\n",centerTerm)
						term=nth(centerTerm termList)
						
						fig=car(car(term~>term~>pins)~>figs)
						list1=findAbsInstFigBBox(fig inst)
						shapeLeft=nth(0 list1)-(caMinW-metal1minW)/2
						shapeBottom=nth(1 list1)
						shapeRight=nth(2 list1)+(caMinW-metal1minW)/2
						shapeTop=nth(3 list1)
						
						term=car(setof(term inst~>instTerms rexMatchp(gateTermMatchName term~>name)))
						fig=car(car(term~>term~>pins)~>figs)
						bBox=dbTransformBBox(fig~>bBox dbGetInstTransform(list(inst)))
						gateShapeBottom=cadr(car(bBox))
						gateShapeTop=cadr(cadr(bBox))
						
						if(gateShapeBottom<shapeBottom then
							shapeBottom=gateShapeBottom-caMinExtCB
						else
							shapeTop=gateShapeTop+caMinExtCB
						)
						dbCreateRect(cvLay1 list(ca_layer "drawing") list(shapeLeft:shapeBottom shapeRight:shapeTop))
						
						;;Add CB and CA (assuming FETs have no poly contacts)
						when(numofFingers==2
							gateCenterY=cadr(centerBox(bBox))
							shapeBottom=gateCenterY-metal1minW/2
							shapeTop=gateCenterY+metal1minW/2
							shapeLeft=bBoxLeft(bBox)-polyPitch
							shapeRight=bBoxRight(bBox)+polyPitch
							dbCreateRect(cvLay1 list(metal1layer "drawing") list(shapeLeft:shapeBottom shapeRight:shapeTop))
						)
					)
				)
			k=k+1
			)
		)
		
		;;Connect gates of dummy cells (3 adjacent single-finger)
		;flattenInstList=list()
		for(i 1 numofRows
			instList=generatedRowInstTable[i]
			k=0
			foreach(inst instList
				instTerms=inst~>instTerms
				when(rexMatchp("DUMMY" inst~>name)
					printf("dummy cell:%s\n",inst~>name)
					numofFingers=get(inst numofFingersParam)
					when(stringp(numofFingers) numofFingers=atoi(numofFingers))
					when(numofFingers==1
						when(k>0
							leftInst=nth((k-1) instList)
							rightInst=nth((k+1) instList)
							when(rexMatchp("DUMMY" leftInst~>name) && rexMatchp("DUMMY" rightInst~>name)
								leftNumofFingers=get(leftInst numofFingersParam)
								when(stringp(leftNumofFingers) leftNumofFingers=atoi(leftNumofFingers))
								rightNumofFingers=get(rightInst numofFingersParam)
								when(stringp(rightNumofFingers) rightNumofFingers=atoi(rightNumofFingers))
								when(leftNumofFingers==1 && rightNumofFingers==1
									;flattenInstList=append(flattenInstList list(inst))
									gateTerm=car(setof(term inst~>instTerms rexMatchp(gateTermMatchName term~>name)))
									gateTermPin=car(car(gateTerm~>term~>pins)~>figs)
									gateTermPinBBox=dbTransformBBox(gateTermPin~>bBox dbGetInstTransform(list(inst)))
									leftGateTerm=car(setof(term leftInst~>instTerms rexMatchp(gateTermMatchName term~>name)))
									leftGateTermPin=car(car(leftGateTerm~>term~>pins)~>figs)
									leftGateTermPinBBox=dbTransformBBox(leftGateTermPin~>bBox dbGetInstTransform(list(leftInst)))
									delta=cadar(leftGateTermPinBBox)-cadar(gateTermPinBBox)
									cbShape=cadr(car(dbGetTrueOverlaps(cvLay1 gateTermPinBBox cb_layer 0:1)))
									cbShapeBBox=dbTransformBBox(cbShape~>bBox dbGetInstTransform(list(inst)))
									
									;param1=polyContOffsetTopParam
									;when(get(inst polyContBottomParam)==polyContBottomTrue
									;	param1=polyContOffsetBottomParam
									;)
									leSetEnv("abutServerOn" nil)
									putprop(inst polyContTopFalse polyContTopParam)
									putprop(inst polyContBottomFalse polyContBottomParam)
									leSetEnv("abutServerOn" t)
									
									;v0shape=cadr(car(dbGetTrueOverlaps(cvLay1 gateTermPinBBox via0layer 0:1)))
									;dbDeleteObject(v0shape)
									;cbShape=cadr(car(dbGetTrueOverlaps(cvLay1 gateTermPinBBox cb_layer 0:1)))
									;cbShapeBBox=dbTransformBBox(cbShape~>bBox dbGetInstTransform(list(inst)))
									;dbMoveFig(cbShape nil list(0:delta "R0"))
									pcPitch=parseFloatString(get(inst fetPCpitchParam))
									;shapeLeft=getBBoxLeft(cbShape)-pcPitch
									;shapeRight=getBBoxRight(cbShape)+pcPitch
									;cbShape~>bBox=list(list(shapeLeft getBBoxBottom(cbShape)) list(shapeRight getBBoxTop(cbShape)))
									;dbMoveFig(gateTermPin nil list(0:delta "R0"))
									shapeLeft=caar(gateTermPinBBox)-pcPitch
									shapeRight=caadr(gateTermPinBBox)+pcPitch
									shapeBottom=cadar(gateTermPinBBox)+delta
									shapeTop=cadadr(gateTermPinBBox)+delta
									dbCreateRect(cvLay1 list(metal1layer "drawing") list(shapeLeft:shapeBottom shapeRight:shapeTop))
									
									shapeLeft=caar(cbShapeBBox)-pcPitch
									shapeRight=caadr(cbShapeBBox)+pcPitch
									shapeBottom=shapeBottom+(metal1minW-cbMinW)/2
									shapeTop=shapeTop-(metal1minW-cbMinW)/2
									dbCreateRect(cvLay1 list(cb_layer "drawing") list(shapeLeft:shapeBottom shapeRight:shapeTop))
									
									sourceTerm=car(setof(term inst~>instTerms rexMatchp(sourceTermMatchName term~>name)))
									sourceTermPin=car(car(sourceTerm~>term~>pins)~>figs)
									sourceTermPinBBox=dbTransformBBox(sourceTermPin~>bBox dbGetInstTransform(list(inst)))
									shapeLeft=caar(sourceTermPinBBox)-(caMinW-metal1minW)/2
	 								shapeBottom=cadar(sourceTermPinBBox)
	 								shapeRight=caadr(sourceTermPinBBox)+(caMinW-metal1minW)/2
	 								shapeTop=cadadr(sourceTermPinBBox)
	 								gateShapeBottom=cadar(leftGateTermPinBBox)
	 								gateShapeTop=cadadr(leftGateTermPinBBox)
	 								if(gateShapeBottom<shapeBottom then
	 									shapeBottom=gateShapeBottom-caMinExtCB
	 								else
	 									shapeTop=gateShapeTop+caMinExtCB
	 								)
	 								dbCreateRect(cvLay1 list(ca_layer "drawing") list(shapeLeft:shapeBottom shapeRight:shapeTop))	 								
								)
							)
						)
					)
				)
				k=k+1
			)
		)
		
		;;Connect gates of dummy cells (2 adjacent single-finger, gate term disabled)
		for(i 1 numofRows
			instList=generatedRowInstTable[i]
			k=0
			foreach(inst instList
				instTerms=inst~>instTerms
				when(rexMatchp("DUMMY" inst~>name)
					printf("dummy cell:%s\n",inst~>name)
					numofFingers=get(inst numofFingersParam)
					when(stringp(numofFingers) numofFingers=atoi(numofFingers))
					when(numofFingers==1
						when(k>0
							leftInst=nth((k-1) instList)
							rightInst=nth((k+1) instList)
							rightInst2=nth((k+2) instList)
							leftInstNumofFingers=get(leftInst numofFingersParam)
							when(stringp(leftInstNumofFingers) leftInstNumofFingers=atoi(leftInstNumofFingers))
							rightInst2NumofFingers=get(rightInst2 numofFingersParam)
							when(stringp(rightInst2NumofFingers) rightInst2NumofFingers=atoi(rightInst2NumofFingers))
							when((!rexMatchp("DUMMY" leftInst~>name) || (rexMatchp("DUMMY" leftInst~>name) && leftInstNumofFingers>1)) && 
								 rexMatchp("DUMMY" rightInst~>name) && 
								 (!rexMatchp("DUMMY" rightInst2~>name) || (rexMatchp("DUMMY" rightInst2~>name) && rightInst2NumofFingers>1))
								rightNumofFingers=get(rightInst numofFingersParam)
								when(stringp(rightNumofFingers) rightNumofFingers=atoi(rightNumofFingers))
								when(rightNumofFingers==1
									printf("found 2 adjacent single-finger dummy devs\n")
									
									sourceTerm=car(setof(x inst~>instTerms rexMatchp(sourceTermMatchName x~>name)))
									drainTerm=car(setof(x inst~>instTerms rexMatchp(drainTermMatchName x~>name)))
									sourceTerm2=car(setof(x rightInst~>instTerms rexMatchp(sourceTermMatchName x~>name)))
									drainTerm2=car(setof(x rightInst~>instTerms rexMatchp(drainTermMatchName x~>name)))
									drawCBoppSide=nil
									when(member(inst noTapCellInstList) &&
										 ((sourceTerm~>net~>name==pwrRailName && drainTerm~>net~>name==pwrRailName) ||
										 (sourceTerm~>net~>name==gndRailName && drainTerm~>net~>name==gndRailName) ||
										 (sourceTerm2~>net~>name==pwrRailName && drainTerm2~>net~>name==pwrRailName) ||
										 (sourceTerm2~>net~>name==gndRailName && drainTerm2~>net~>name==gndRailName))
										drawCBoppSide=t
									)
									
									;;Draw CB
									leftGateTerm=car(setof(term leftInst~>instTerms rexMatchp(gateTermMatchName term~>name)))
									leftGateTermPinBBox=car(leftGateTerm~>term~>pins)~>fig~>bBox
									leftGateTermPinY=cadr(centerBox(leftGateTermPinBBox))
									leftGateTermPos="near"

									if(get(leftInst polyContTopParam)=="TRUE" then
										numofFins=get(leftInst numofFinsParam)
										when(stringp(numofFins) numofFins=atoi(numofFins))
										delta=leftGateTermPinY-((numofFins-1)*finPitch+finThickness)
										when(abs(delta)>gateTermPosThreshold leftGateTermPos="far")
									else
										when(abs(leftGateTermPinY)>gateTermPosThreshold leftGateTermPos="far")
									)
									
									leftGateTermPinBBoxAbs=dbTransformBBox(leftGateTermPinBBox dbGetInstTransform(list(leftInst)))
									leftGateTermPinYabs=cadr(centerBox(leftGateTermPinBBoxAbs))
									if(drawCBoppSide then
										if(get(leftInst polyContTopParam)=="TRUE" then
											shapeCenterY=cadr(inst~>xy)-cbOffsetFromNearestFin
										else
											numofFins=get(inst numofFinsParam)
											when(stringp(numofFins) numofFins=atoi(numofFins))
											shapeCenterY=cadr(inst~>xy)+(numofFins-1)*finPitch+finThickness+cbOffsetFromNearestFin
										)
									else
										if(leftGateTermPos=="near" then
											if(get(leftInst polyContTopParam)=="TRUE" then
												shapeCenterY=leftGateTermPinYabs+polyContOffset
											else
												shapeCenterY=leftGateTermPinYabs-polyContOffset
											)
										else
											if(get(leftInst polyContTopParam)=="TRUE" then
												shapeCenterY=leftGateTermPinYabs-polyContOffset
											else
												shapeCenterY=leftGateTermPinYabs+polyContOffset
											)
										)
									)
									
									shapeBottom=shapeCenterY-cbMinW/2
									shapeTop=shapeCenterY+cbMinW/2
									shapeLeft=car(inst~>xy)-cbMinExtPoly
									shapeRight=shapeLeft+2*cbMinExtPoly+polyPitch+polyMinW
									when(drawCBoppSide
										shapeLeft=shapeLeft-cbExtOverlapCA
										shapeRight=shapeRight+cbExtOverlapCA
									)
									dbCreateRect(cvLay1 list(cb_layer "drawing") list(shapeLeft:shapeBottom shapeRight:shapeTop))
									
									;;Extend poly to overlap CB
									shapeLeft=car(inst~>xy)
									shapeRight=shapeLeft+polyMinW
									if(drawCBoppSide then
										if(get(leftInst polyContTopParam)=="TRUE" then
											shapeBottom=shapeBottom-polyExtCB
											shapeTop=cadr(inst~>xy)
										else
											shapeBottom=cadr(inst~>xy)
											shapeTop=shapeTop+polyExtCB
										)
									else
										if(get(leftInst polyContTopParam)=="TRUE" then
											shapeBottom=cadr(inst~>xy)
											shapeTop=shapeTop+polyExtCB
											when(leftGateTermPos=="far" shapeTop=shapeTop+polyContOffset)
										else
											shapeBottom=shapeBottom-polyExtCB
											when(leftGateTermPos=="far" shapeBottom=shapeBottom-polyContOffset)
											shapeTop=cadr(inst~>xy)
										)
									)
									dbCreateRect(cvLay1 list(poly_layer "drawing") list(shapeLeft:shapeBottom shapeRight:shapeTop))
									shapeLeft2=shapeLeft-(trenchSilicideBlockMinW-polyMinW)/2
									shapeRight2=shapeLeft2+trenchSilicideBlockMinW
									dbCreateRect(cvLay1 list(trenchSilicideBlockLayer "drawing") list(shapeLeft2:shapeBottom shapeRight2:shapeTop))
									
									shapeLeft=shapeLeft+polyPitch
									shapeRight=shapeLeft+polyMinW
									dbCreateRect(cvLay1 list(poly_layer "drawing") list(shapeLeft:shapeBottom shapeRight:shapeTop))
									shapeLeft2=shapeLeft-(trenchSilicideBlockMinW-polyMinW)/2
									shapeRight2=shapeLeft2+trenchSilicideBlockMinW
									dbCreateRect(cvLay1 list(trenchSilicideBlockLayer "drawing") list(shapeLeft2:shapeBottom shapeRight2:shapeTop))
									
									;;Draw CA
									sourceTerm=car(setof(term inst~>instTerms rexMatchp(sourceTermMatchName term~>name)))
									sourceTermPin=car(car(sourceTerm~>term~>pins)~>figs)
									sourceTermPinBBox=dbTransformBBox(sourceTermPin~>bBox dbGetInstTransform(list(inst)))
									sourceTermPinX=car(centerBox(sourceTermPinBBox))
									drainTerm=car(setof(term inst~>instTerms rexMatchp(drainTermMatchName term~>name)))
									drainTermPin=car(car(drainTerm~>term~>pins)~>figs)
									drainTermPinBBox=dbTransformBBox(drainTermPin~>bBox dbGetInstTransform(list(inst)))
									drainTermPinX=car(centerBox(drainTermPinBBox))
									if(sourceTermPinX>drainTermPinX then
										shapeCenterX=sourceTermPinX
									else
										shapeCenterX=drainTermPinX
									)
									shapeLeft=shapeCenterX-caMinW/2
									shapeRight=shapeCenterX+caMinW/2
									if(drawCBoppSide then
										if(get(leftInst polyContTopParam)=="TRUE" then
											shapeTop=cadr(inst~>xy)
											shapeBottom=shapeCenterY-cbMinW/2-caMinExtCB
										else
											shapeBottom=cadr(inst~>xy)
											shapeTop=shapeCenterY+cbMinW/2+caMinExtCB
										)
									else
										if(get(leftInst polyContTopParam)=="TRUE" then
											shapeBottom=cadr(inst~>xy)
											shapeTop=shapeCenterY+cbMinW/2+caMinExtCB
										else
											shapeTop=cadr(inst~>xy)
											shapeBottom=shapeCenterY-cbMinW/2-caMinExtCB
										)
									)
									dbCreateRect(cvLay1 list(ca_layer "drawing") list(shapeLeft:shapeBottom shapeRight:shapeTop))
									
									when(drawCBoppSide
										if(sourceTermPinX>drainTermPinX then
											when(drainTerm~>net~>name==pwrRailName || drainTerm~>net~>name==gndRailName
												shapeCenterX=drainTermPinX
												shapeLeft=shapeCenterX-caMinW/2
												shapeRight=shapeCenterX+caMinW/2
												dbCreateRect(cvLay1 list(ca_layer "drawing") list(shapeLeft:shapeBottom shapeRight:shapeTop))
											)
										else
											when(sourceTerm~>net~>name==pwrRailName || sourceTerm~>net~>name==gndRailName
												shapeCenterX=sourceTermPinX
												shapeLeft=shapeCenterX-caMinW/2
												shapeRight=shapeCenterX+caMinW/2
												dbCreateRect(cvLay1 list(ca_layer "drawing") list(shapeLeft:shapeBottom shapeRight:shapeTop))
											)
										)
										
										sourceTerm2=car(setof(term rightInst~>instTerms rexMatchp(sourceTermMatchName term~>name)))
										sourceTermPin2=car(car(sourceTerm2~>term~>pins)~>figs)
										sourceTermPinBBox2=dbTransformBBox(sourceTermPin2~>bBox dbGetInstTransform(list(rightInst)))
										sourceTermPinX2=car(centerBox(sourceTermPinBBox2))
										drainTerm2=car(setof(term rightInst~>instTerms rexMatchp(drainTermMatchName term~>name)))
										drainTermPin2=car(car(drainTerm2~>term~>pins)~>figs)
										drainTermPinBBox2=dbTransformBBox(drainTermPin2~>bBox dbGetInstTransform(list(rightInst)))
										drainTermPinX2=car(centerBox(drainTermPinBBox2))
										if(sourceTermPinX2>drainTermPinX2 then
											when(sourceTerm2~>net~>name==pwrRailName || sourceTerm2~>net~>name==gndRailName
												shapeCenterX=sourceTermPinX2
												shapeLeft=shapeCenterX-caMinW/2
												shapeRight=shapeCenterX+caMinW/2
												dbCreateRect(cvLay1 list(ca_layer "drawing") list(shapeLeft:shapeBottom shapeRight:shapeTop))
											)
										else
											when(drainTerm2~>net~>name==pwrRailName || drainTerm2~>net~>name==gndRailName
												shapeCenterX=drainTermPinX2
												shapeLeft=shapeCenterX-caMinW/2
												shapeRight=shapeCenterX+caMinW/2
												dbCreateRect(cvLay1 list(ca_layer "drawing") list(shapeLeft:shapeBottom shapeRight:shapeTop))
											)
										)
									)
									
									;;Draw poly cut layer
									shapeList=dbGetTrueOverlaps(cvLay1 leftInst~>bBox polyCutLayer 0:1)
									;if(member(inst~>cellName pfetList) then
									if(get(leftInst polyContBottomParam)=="TRUE" then
										shapeBottom=1000
									else
										shapeBottom=-1000
									)
									foreach(shape shapeList
										when(listp(shape)
											inst1=car(shape)
											shape=cadr(shape)
											shapeBBox=dbTransformBBox(shape~>bBox dbGetInstTransform(list(inst1)))
											;if(member(inst~>cellName pfetList) then
											if(get(leftInst polyContBottomParam)=="TRUE" then
												if(bBoxBottom(shapeBBox)<shapeBottom then
													shapeBottom=bBoxBottom(shapeBBox)
												)
											else
												if(bBoxBottom(shapeBBox)>shapeBottom then
													shapeBottom=bBoxBottom(shapeBBox)
												)
											)
										)
									)
									shapeTop=shapeBottom+polyCutW
									shapeLeft=getBBoxLeft(inst)
									shapeRight=getBBoxRight(inst)
									dbCreateRect(cvLay1 list(polyCutLayer "drawing") list(shapeLeft:shapeBottom shapeRight:shapeTop))
								)
							)
						)
					)
				)
				k=k+1
			)
		)
		
		;;Shorten M1 gate pin (if necessary) to avoid violating min M1 spacing rule during gate routing
		gatePinModificationTable=makeTable("gatePinModificationTable")
		for(i 1 numofRows
			printf("row %d\n",i)
			instList=generatedRowInstTable[i]
			foreach(inst instList
				when(inst~>cellName!=tapCellName
					printf("%s\n",inst~>name)
					numofFingers=get(inst numofFingersParam)
					when(stringp(numofFingers) numofFingers=atoi(numofFingers))
					;when(numofFingers>1 && CCSfindAbutChain(inst)
					when(CCSfindAbutChain(inst)
						m1GatePin=car(car(setof(term inst~>instTerms rexMatchp(gateTermMatchName term~>name)))~>term~>pins)~>fig
						m1GatePinLeftRel=getBBoxLeft(m1GatePin)
						printf("%f\n",m1GatePinLeftRel)
						when(m1GatePinLeftRel<0
							printf("m1GatePin:%f\n",m1GatePinLeftRel)
							bBox=dbTransformBBox(m1GatePin~>bBox dbGetInstTransform(list(inst)))
							m1GatePinRightRel=getBBoxRight(m1GatePin)
							m1GatePinBottomRel=getBBoxBottom(m1GatePin)
							m1GatePinTopRel=getBBoxTop(m1GatePin)
							m1GatePinRightRel=m1GatePinRightRel+m1GatePinLeftRel
							m1GatePin~>bBox=list(list(0 m1GatePinBottomRel) list(m1GatePinRightRel m1GatePinTopRel))
							gatePinModificationTable[m1GatePin]=m1GatePinLeftRel
							;m1GatePinLeftAbs=caar(bBox)
							;m1GatePinRightAbs=caadr(bBox)
							;m1GatePinBottomAbs=cadar(bBox)
							;m1GatePinTopAbs=m1GatePinBottomAbs+metal1minW
							;printf("%s %f %f %f %f\n",inst~>name,m1GatePinLeftAbs,m1GatePinRightAbs,m1GatePinBottomAbs,m1GatePinBottomRel)
							
							;v0list=dbGetTrueOverlaps(cvLay1 list(m1GatePinLeftAbs:m1GatePinBottomAbs m1GatePinRightAbs:m1GatePinTopAbs) via0layer 0:1)
							;printf("%L\n",v0list)
							;v0leftMost=cadr(car(v0list))
							;v0rightMost=cadr(car(last(v0list)))
							;printf("delete %s\n",v0leftMost)
							;dbDeleteObject(v0leftMost)
							;dbDeleteObject(v0rightMost)
							
							;gatePinEditingTable[inst]=list(dbTransformBBox(v0leftMost~>bBox dbGetInstTransform(list(inst))) dbTransformBBox(v0rightMost~>bBox dbGetInstTransform(list(inst))))
							
							;when(length(v0list)==2
							;	shapeCenter=(m1GatePinLeftAbs+m1GatePinRightAbs)/2
							;	shapeLeft=shapeCenter-(via0size/2)
							;	shapeRight=shapeLeft+via0size
							;	dbCreateRect(cvLay1 list(via0layer "drawing") list(shapeLeft:m1GatePinBottomAbs shapeRight:m1GatePinTopAbs))
							;)
						)
					)
				)
			)
		)
		printstruct(gatePinModificationTable)
	    	
		;;Modify IO pin layer/purpose and location according to ref layout
		foreach(shape setof(x cvLay1~>shapes x~>objType=="label")
			dbDeleteObject(shape)
		)
		bBoxRightMax2=0
		foreach(termName ioPinTable
			printf("termName:%s\n",termName)
			term=pinIDtable[termName]
			pinLayer=nth(0 ioPinTable[termName])
			pinPurpose=nth(1 ioPinTable[termName])
			pinWidth=nth(4 ioPinTable[termName])
			pinHeight=nth(5 ioPinTable[termName])
			vfpSbEditIOPin(list(libName cellName layViewName) termName ?lpp list(pinLayer pinPurpose) ?width pinWidth ?height pinHeight)
			
			xOffset=nth(2 ioPinTable[termName])
			if(member(termName rhsPinTable) then
				;printf("rhs pin:%s\n",termName)
				xOffset=bBoxRightMax+rhsPinTable[termName]
			)
			when(member(termName centerPinList)
				rowCenterX=(bBoxLeftMin+bBoxRightMax)/2
				xOffset=rowCenterX-pinWidth/2+nth((lindex(centerPinList termName)-1) centerPinOffsetList)
				printf("%s %f %f\n",termName,rowCenterX,nth((lindex(centerPinList termName)-1) centerPinOffsetList))
			)
			
			when(pinLayer!=metal1layer
				layerAbove=nth(lindex(metalLayerList pinLayer) metalLayerList)
				printf("layerAbove:%s %d\n",layerAbove,lindex(metalLayerList pinLayer))
				float1=float(mod(round((xOffset+pinWidth/2)*1000) round(trackSpacing[layerAbove]*1000)))/1000
				printf("remainder:%f %d %d %d\n",float1,round((xOffset+pinWidth/2)*1000),round(trackSpacing[layerAbove]*1000),mod(round((xOffset+pinWidth/2)*1000) round(trackSpacing[layerAbove]*1000)))
				if(float1>trackSpacing[layerAbove]/2 then
					xOffset=xOffset+trackSpacing[layerAbove]-float1
				else
					xOffset=xOffset-float1
				)
			)
			
			inst=dbFindAnyInstByName(cvLay1 nth(0 ioPinRelPosTable[termName]))
			yOffset=getBBoxSelSide(inst nth(1 ioPinRelPosTable[termName]))+nth(2 ioPinRelPosTable[termName])
			when(pinLayer!=metal1layer && pinLayer!=metal2layer
				num1=mod(round(yOffset*1000) round(trackSpacing[pinLayer]*1000))
				if(num1>trackSpacing[pinLayer]*1000/2 then
					yOffset=yOffset+float(trackSpacing[pinLayer]*1000-num1)/1000
				else
					yOffset=yOffset-float(num1)/1000
				)
			)
			
			pinFig=car(term~>pins)~>fig
			shiftX=-getBBoxLeft(pinFig)+xOffset
			shiftY=-getBBoxBottom(pinFig)-pinHeight/2+yOffset
			dbMoveFig(pinFig nil list(shiftX:shiftY "R0"))
			
			bBoxRight=getBBoxRight(pinFig)
			when(bBoxRight>bBoxRightMax2
				bBoxRightMax2=bBoxRight
			)
		)
		;printf("chk:rightMax:%f\n",rightMax)
		
		;;Create IO pin labels
		foreach(term cvLay1~>terminals
			foreach(fig term~>pins~>fig
				label=dbCreateLabel(cvLay1 list(fig~>layerName "label") centerBox(fig~>bBox) term~>name "centerCenter" "R0" "roman" 0.05)
				leAttachFig(label fig)
	         )
	    )
	    
	    ;;Move pin guides according to ref layout
	    pinGuideList=list()
	    foreach(pinFig pinFigTable
	    		pinLayer=nth(0 pinFigTable[pinFig])
			pinPurpose=nth(1 pinFigTable[pinFig])
			pinWidth=nth(4 pinFigTable[pinFig])
			pinHeight=nth(5 pinFigTable[pinFig])
			shapeLeft=nth(2 pinFigTable[pinFig])-pinHeight/2
			shapeRight=shapeLeft+pinWidth
			inst=dbFindAnyInstByName(cvLay1 nth(0 pinFigRelPosTable[pinFig]))
			yOffset=getBBoxSelSide(inst nth(1 pinFigRelPosTable[pinFig]))+nth(2 pinFigRelPosTable[pinFig])
			yOffset=snap(yOffset trackSpacing[pinLayer] ?direction "bottom")
			shapeBottom=yOffset-pinHeight/2
			shapeTop=shapeBottom+pinHeight
			fig=dbCreateRect(cvLay1 list(pinLayer pinPurpose) list(shapeLeft:shapeBottom shapeRight:shapeTop))
			net=dbFindNetByName(cvLay1 pinFig~>net~>name)
			printf("pinFig net name:%s %s\n",pinFig~>net~>name,net)
			;dbAddFigToNet(fig net)
			pinGuide=dbCreatePin(net fig)
			pinGuideList=append(pinGuideList list(pinGuide))
	    )
	    lceExtract(cvLay1)
	    
		;;Recreate nwell shapes from ref layout
		foreach(i nwellShapeTable
			/*
			bottomRow=car(nwellShapeTable[i])
			topRow=car(last(nwellShapeTable[i]))
			shapeBottom=getBBoxBottom(car(generatedRowInstTable[bottomRow]))
			shapeTop=getBBoxTop(car(generatedRowInstTable[topRow]))
			shapeLeft=100
			shapeRight=0
			foreach(k nwellShapeTable[i]
				rowLeft=getBBoxLeft(car(generatedRowInstTable[j]))
				when(rowLeft<shapeLeft
					shapeLeft=rowLeft
				)
				rowRight=getBBoxRight(car(last(generatedRowInstTable[j])))
				when(rowRight>shapeRight
					shapeRight=rowRight
				)
			)
			*/
			shapeLeft=100
			shapeRight=0
			shapeTop=0
			shapeBottom=100
			foreach(instName nwellShapeTable[i]
				inst=instIDtable[instName]
				bBoxLeft=getBBoxLeft(inst)
			bBoxBottom=getBBoxBottom(inst)
			bBoxRight=getBBoxRight(inst)
			bBoxTop=getBBoxTop(inst)
			when(bBoxLeft<shapeLeft shapeLeft=bBoxLeft)
			when(bBoxBottom<shapeBottom shapeBottom=bBoxBottom)
			when(bBoxRight>shapeRight shapeRight=bBoxRight)
			when(bBoxTop>shapeTop shapeTop=bBoxTop)
			)
			dbCreateRect(cvLay1 list(nwell_layer "drawing") list(shapeLeft:shapeBottom shapeRight:shapeTop))
		)
		
		;;Create M2 WSPs
		gatePinOffsetTable=makeTable("gatePinOffsetTable")
		for(i 1 numofRows
			gatePinOffsetList=list()
			instList=generatedRowInstTable[i]
			foreach(inst instList
				when(member(inst fetInstList) && (get(inst polyContTopParam)==polyContTopTrue || get(inst polyContBottomParam)==polyContBottomTrue)
					list1=setof(term inst~>instTerms rexMatchp(gateTermMatchName term~>name))
					printf("gateterms:%L\n",list1)
					gateTerm=car(setof(term inst~>instTerms rexMatchp(gateTermMatchName term~>name)))
					m1pin=car(car(gateTerm~>term~>pins)~>figs)
					float1=(getBBoxBottom(m1pin)+getBBoxTop(m1pin))/2
					printf("%s %f\n",inst~>name,float1)
					when(!member(float1 gatePinOffsetList)
						gatePinOffsetList=append(gatePinOffsetList list(float1))
					)
				)
			)
			gatePinOffsetTable[i]=gatePinOffsetList
		)
		;gatePinOffsetList=sort(gatePinOffsetList 'lessp)
		;printf("%L\n",gatePinOffsetList)
		printstruct(gatePinOffsetTable)
		
		m2wspAbs=list()
		for(i 1 numofRows
			instList=generatedRowInstTable[i]
			inst=car(instList)
			when(member(inst fetInstList)
				instY=cadr(inst~>xy)
				foreach(float1 gatePinOffsetTable[i]
					m2wspAbs=append(m2wspAbs list(instY+float1))
				)
				;m2wspAbs=append(m2wspAbs list((instY-gatePinOffset2) (instY-gatePinOffset1) (instY-rxEdgeOffset+metal2minW/2)))
				fingerWidth=get(inst fingerWidthParam)
				when(stringp(fingerWidth)
					cond(
						(pcreMatchp("n" fingerWidth)
							fingerWidth=cdfParseFloatString(fingerWidth)*1e6
						)
						(t
							fingerWidth=cdfParseFloatString(fingerWidth)
						)
					)
				)

				sourceTermBBox=car(car(setof(x inst~>instTerms rexMatchp(sourceTermMatchName x~>name)))~>term~>pins)~>fig~>bBox
				sourceTermBBoxBottom=bBoxBottom(sourceTermBBox)
				sourceTermBBoxTop=bBoxTop(sourceTermBBox)				
				;float1=metal2minW/2
				float1=instY+sourceTermBBoxBottom+stdVia1layer1Enc+metal2minW/2
				;while(float1<fingerWidth
				while(float1<instY+sourceTermBBoxTop-stdVia1layer1Enc-metal2minW/2
					;m2wspAbs=append(m2wspAbs list(instY-halfFinSpacing+float1))
					m2wspAbs=append(m2wspAbs list(float1))
					float1=float1+metal2minPitch+metal2minPitchExtra ;;metal2minPitchExtra is added to avoid GF12LP GRVx.S.Vy.1b_V1: V1 minimum center-to-center space to V2 >= 0.068 (different net)
				)
				;m2wspAbs=append(m2wspAbs list((instY+fingerWidth-2*rxEdgeOffset+gatePinOffset1) (instY+fingerWidth-2*rxEdgeOffset+gatePinOffset2)))
			)
		)
		m2wspAbs=sort(m2wspAbs 'lessp)
		;printf("m2wspAbs:%L\n",m2wspAbs)
		m2wsp=list(nth(0 m2wspAbs))
		for(i 1 length(m2wspAbs)-1
			m2wsp=append(m2wsp list((nth(i m2wspAbs)-nth((i-1) m2wspAbs))))
		)
		;printf("m2wsp:%L\n",m2wsp)
		
		outPort=outfile("createM2wsp.il")
		fprintf(outPort "procedure(createM2wsp(cv)\n")
		fprintf(outPort "\tlet(()\n")
		fprintf(outPort "\t\twspCreateWSP(cv \"wspCreateWSP_M2\"\n")
		for(i 0 length(m2wsp)-1
			fprintf(outPort "\t\t\t%.3f %.3f\n",metal2minW,nth(i m2wsp))
		)
		fprintf(outPort "\t\t)\n")
		fprintf(outPort "\t\twspCreateWSSPDef(cv \"wspCreateWSSPDef_M2\" \"%s\" \"vertical\" 1000 ?defaultActive \"wspCreateWSP_M2\")\n",metal2layer)
		fprintf(outPort "\t)\n")
		fprintf(outPort ")\n")
		close(outPort)
				
		load("./createM2wsp.il")
		createM2wsp(cvLay1)
		setWSP(cvLay1)
	    
		;;Route incomplete nets
		;when(route autoRoute(cvLay1 cvSch VSRpreset ?priorityRoute priorityRoute ?constraintsFile constraintsFile ?routeNets routeNets))
		when(route
			;;Read route directives
			routeDirective=makeTable("routeDirective")
			;routeDirective["CLK_C-2_5-bottom_term"]="CONNECT"
			;routeDirective["CLK_C-2_5-top_term"]="DO_NOT_CONNECT"
			;routeDirective["CLK_C-2_5-trunk"]=list("5_6" "K2")
			inPort=infile(routeDirectiveFile)
			unless(inPort error("Cannot open route directive file %s\n",routeDirectiveFile))
			printf("Reading route directive file %s\n",routeDirectiveFile)
			while(gets(inLine inPort)
				if(rexMatchp("^NET:" inLine) then
					net=cadr(parseString(inLine ":\n"))
					printf("net:%s\n",net)
				else
					fieldList=parseString(inLine ",\n")
					trunk=car(fieldList)
					foreach(field cdr(fieldList)
						keyword=car(parseString(field ":"))
						sprintf(routeDirectiveKey "%s-%s-%s",net,trunk,keyword)
						value=cadr(parseString(field ":"))
						valueList=parseString(value " ")
						if(length(valueList)>1 then
							routeDirective[routeDirectiveKey]=valueList
						else
							routeDirective[routeDirectiveKey]=value
						)
					)
				)
			)
			printstruct(routeDirective)
			
			lxUpdateBinding(cvLay1 ?schCV cvSch)
			;setWSP(cvLay)
			vsrLoadPreset(VSRpreset)
			
			tech=techGetTechFile(cvLay1)
			stdVia1def=techFindViaDefByName(tech stdVia1defName)
			stdVia2def=techFindViaDefByName(tech stdVia2defName)
			stdVia3def=techFindViaDefByName(tech stdVia3defName)
			
			;incompleteNets=reverse(sort(lceGetIncompleteNets(cvLay)~>name 'alphalessp))
			when(!routeNets
				routeNets=reverse(sort(lceGetIncompleteNets(cvLay1)~>name 'alphalessp))
			)
			;printf("Nets to be routed:%L\n",routeNets)
			
			;;Read net priority from constraints file and prioritize nets for routing
			when(priorityRoute
				CCSgenCSVconstraints(constraintsFile)
				unless(constraintsFile error("Constraints file is required when priority route is enabled\n"))
				inPort=infile(constraintsFile)
				unless(inPort error("Cannot open file \"%s\"\n" constraintsFile))
				printf("Reading net routing priority from \"%s\"\n" constraintsFile)
				priorityTable=makeTable("priorityTable")
				while(gets(inLine inPort)
					inLineList=parseString(inLine ",\n")
					when(car(inLineList)=="priority"
						nets=parseString(nth(2 inLineList))
						priority=nth(0 parseString(nth(2 parseString(nth(3 inLineList))) ")"))
						priority=atoi(priority)
						priorityTable[priority]=nets
					)
				)
				close(inPort)
				;printstruct(priorityTable)
				
				priorityList=list()
				foreach(priority priorityTable
					priorityList=append(priorityList list(priority))
				)
				priorityList=reverse(sort(priorityList 'lessp))
			)
		
			outPort=outfile("./vsr.log")
			printf("Beginning to route (log: vsr.log)\n")
			;useInternalRoute=list("S" "SB")
			instListGateConnected=list()
			if(priorityRoute then
			    foreach(priority priorityList
			    		nets=priorityTable[priority]
			    		netsFiltered=setof(x nets member(x routeNets))
			    		when(netsFiltered
						printf("Routing %L\n",nets)
	      				if(member(car(nets) useInternalRoute) then
	      					;;Internal route limitations:
	      					;;Only for nets connected to an IO pin and gate pins
	      					netName=car(nets)
	      					printf("internal route: %s\n",netName)
							net=dbFindNetByName(cvLay1 netName)
							
							ioPinFig=car(net~>term~>pins)~>fig
							ioPinBBox=ioPinFig~>bBox
							ioPinCenterX=car(centerBox(ioPinBBox))
							ioPinCenterY=cadr(centerBox(ioPinBBox))
							printf("io:%f %f\n",ioPinCenterX,ioPinCenterY)
							
							instTerms=net~>instTerms
							instList=instTerms~>inst
							i=0
							metal4pathRight=getBBoxRight(ioPinFig)
							metal4pathLeft=getBBoxLeft(ioPinFig)
							;tech=techGetTechFile(cvLay1)
							;stdVia1def=techFindViaDefByName(tech stdVia1defName)
							;stdVia2def=techFindViaDefByName(tech stdVia2defName)
							;stdVia3def=techFindViaDefByName(tech stdVia3defName)
							foreach(term instTerms~>term
								fig=car(term~>pins)~>fig
								bBox=dbTransformBBox(fig~>bBox dbGetInstTransform(list(nth(i instList))))
								i=i+1
								printf("inst term:%L\n",bBox)
								bBoxCenter=centerBox(bBox)
								bBoxCenterX=car(bBoxCenter)
								bBoxCenterY=cadr(bBoxCenter)
								bBoxRight=bBoxRight(bBox)
								bBoxLeft=bBoxLeft(bBox)
								;when(bBoxCenterX>metal4pathRight metal4pathRight=bBoxCenterX)
								;when(bBoxCenterX<metal4pathLeft metal4pathLeft=bBoxCenterX)
								;when(bBoxRight>metal4pathRight metal4pathRight=bBoxRight)
								;when(bBoxLeft<metal4pathLeft metal4pathLeft=bBoxLeft)
								
								cutRows=int(((bBoxRight(bBox)-bBoxLeft(bBox))-2*stdVia1layer2Enc)/(stdVia1minCutspacing+via1size))+1
								dbCreateVia(cvLay1 stdVia1def bBoxCenter "R90" list(list("cutRows" cutRows) list("cutSpacing" list(stdVia1minCutspacing stdVia1minCutspacing))))
								
								if(bBoxCenterY>ioPinCenterY then
									;metal3pathTop=bBoxCenterY
									;metal3pathBottom=ioPinCenterY
									metal3pathTop=bBoxCenterY+via3size/2+stdVia3layer1Enc
									metal3pathBottom=ioPinCenterY-via3size/2-stdVia3layer1Enc
								else
									metal3pathTop=ioPinCenterY+via3size/2+stdVia3layer1Enc
									metal3pathBottom=bBoxCenterY-via3size/2-stdVia3layer1Enc
								)
								/*
								metal3pathCenter=bBoxCenterX-float(mod(round(bBoxCenterX*1000) round(trackSpacing[metal3layer]*1000)))/1000
								metal3pathLeft=metal3pathCenter-metal3minW/2
								metal3pathRight=metal3pathCenter+metal3minW/2
								list1=dbGetTrueOverlaps(cvLay1 list(list(metal3pathLeft metal3pathBottom) list(metal3pathRight metal3pathTop)) metal3layer)
								when(list1
									metal3pathCenter=metal3pathCenter+trackSpacing[metal3layer]
									metal3pathLeft=metal3pathCenter-metal3minW/2
									metal3pathRight=metal3pathCenter+metal3minW/2
								)
								*/
								metal3pathCenter=snap(bBoxCenterX trackSpacing[metal3layer] ?direction "left")
								metal3pathCenter=findTrack(cvLay1 metal3pathCenter (metal3pathBottom-lineEndSpacing[metal3layer]+0.001) (metal3pathTop+lineEndSpacing[metal3layer]-0.001) "vertical" trackSpacing[metal3layer] trackWidth[metal3layer] metal3layer net "both")
								;when(metal3pathCenter>metal4pathRight metal4pathRight=metal3pathCenter)
								;when(metal3pathCenter<metal4pathLeft metal4pathLeft=metal3pathCenter)
								metal3pathCenterFirst=metal3pathCenter
								while(metal3pathCenter>bBoxLeft
									when(metal3pathCenter<metal4pathLeft metal4pathLeft=metal3pathCenter)
									
									metal3pathLeft=metal3pathCenter-metal3minW/2
									metal3pathRight=metal3pathCenter+metal3minW/2
									leCreatePath(cvLay1 list(metal3layer "drawing") list(metal3pathCenter:metal3pathTop metal3pathCenter:metal3pathBottom) metal3minW)
									dbCreateVia(cvLay1 stdVia2def list(metal3pathCenter bBoxCenterY) "R0" list(list("layer1Enc" list(stdVia2layer1Enc 0))))
									dbCreateVia(cvLay1 stdVia3def list(metal3pathCenter ioPinCenterY) "R0" list(list("layer2Enc" list(stdVia3layer2Enc 0))))
									
									metal3pathCenter=metal3pathCenter-meshSpacing[metal3layer]
									metal3pathCenter=findTrack(cvLay1 metal3pathCenter (metal3pathBottom-lineEndSpacing[metal3layer]+0.001) (metal3pathTop+lineEndSpacing[metal3layer]-0.001) "vertical" trackSpacing[metal3layer] trackWidth[metal3layer] metal3layer net "both")
								)
								metal3pathCenter=metal3pathCenterFirst+meshSpacing[metal3layer]
								while(metal3pathCenter<bBoxRight
									when(metal3pathCenter>metal4pathRight metal4pathRight=metal3pathCenter)
									
									metal3pathLeft=metal3pathCenter-metal3minW/2
									metal3pathRight=metal3pathCenter+metal3minW/2
									leCreatePath(cvLay1 list(metal3layer "drawing") list(metal3pathCenter:metal3pathTop metal3pathCenter:metal3pathBottom) metal3minW)
									dbCreateVia(cvLay1 stdVia2def list(metal3pathCenter bBoxCenterY) "R0" list(list("layer1Enc" list(stdVia2layer1Enc 0))))
									dbCreateVia(cvLay1 stdVia3def list(metal3pathCenter ioPinCenterY) "R0" list(list("layer2Enc" list(stdVia3layer2Enc 0))))
									
									metal3pathCenter=metal3pathCenter+meshSpacing[metal3layer]
									metal3pathCenter=findTrack(cvLay1 metal3pathCenter (metal3pathBottom-lineEndSpacing[metal3layer]+0.001) (metal3pathTop+lineEndSpacing[metal3layer]-0.001) "vertical" trackSpacing[metal3layer] trackWidth[metal3layer] metal3layer net "both")
								)				
							)
							
							metal4pathLeft=metal4pathLeft-stdVia3layer2Enc-via3size/2
							metal4pathRight=metal4pathRight+stdVia3layer2Enc+via3size/2
							leCreatePath(cvLay1 list(metal4layer "drawing") list(metal4pathLeft:ioPinCenterY metal4pathRight:ioPinCenterY) metal4minW)
	      				else
	      					if(member(car(nets) useInternalRoute3) then
	      						netName=car(nets)
	      						net=dbFindNetByName(cvLay1 netName)
	      						internalRoute3(cvLay1 cvSch net instRowTable)
	      					else
		      					hsmSelect(?type 'net ?name nets)
					    			poport=outPort
		      					woport=outPort
		      					errport=outPort
								_iaAutomaticExecuteCmd('autoRoute stringToSymbol("selected"))
								poport=stdout
		      					errport=stderr
		      					woport=stdout
		      					hsmDeselect(?type 'net ?name nets)
		      				)
						)
						
						;;Align stdvia V1 to M1 gate pin (if necessary)
						when(!member(car(nets) useInternalRoute3)
							for(i 1 numofRows
								instList=generatedRowInstTable[i]
								foreach(inst instList
									when(member(inst fetInstList) && (get(inst polyContTopParam)==polyContTopTrue || get(inst polyContBottomParam)==polyContBottomTrue)
										printf("inst:%s\n",inst~>name)
										gateTerm=car(setof(term inst~>instTerms rexMatchp(gateTermMatchName term~>name)))
										m1pin=car(car(gateTerm~>term~>pins)~>figs)
										m1pinBBoxAbs=dbTransformBBox(m1pin~>bBox dbGetInstTransform(list(inst)))
										printf("m1pinBBoxAbs:%L\n",m1pinBBoxAbs)
										m1shapeList=dbGetTrueOverlaps(cvLay1 m1pinBBoxAbs metal1layer 0:1)
										m1shapeBBoxTop=0
										m1shapeBBoxBottom=1000
										m1shapeBBoxLeft=1000
										m1shapeBBoxRight=0
										foreach(m1shape m1shapeList
											if(listp(m1shape) then
												shapeInst=car(m1shape)
												shape=cadr(m1shape)
												shapeBBoxAbs=dbTransformBBox(shape~>bBox dbGetInstTransform(list(shapeInst)))
												bBoxBottom=cadar(shapeBBoxAbs)
												bBoxTop=cadadr(shapeBBoxAbs)
												bBoxLeft=caar(shapeBBoxAbs)
												bBoxRight=caadr(shapeBBoxAbs)
											else
												bBoxBottom=getBBoxBottom(m1shape)
												bBoxTop=getBBoxTop(m1shape)
												bBoxLeft=getBBoxLeft(m1shape)
												bBoxRight=getBBoxRight(m1shape)
												shape=m1shape
											)
											when(bBoxBottom<m1shapeBBoxBottom 
												m1shapeBBoxBottom=bBoxBottom
												;m1shapeBBoxBottomInst=shape
											)
											when(bBoxTop>m1shapeBBoxTop 
												m1shapeBBoxTop=bBoxTop
												;m1shapeBBoxTopInst=shape
											)
											when(bBoxLeft<m1shapeBBoxLeft m1shapeBBoxLeft=bBoxLeft)
											when(bBoxRight>m1shapeBBoxRight m1shapeBBoxRight=bBoxRight)
										)
										m1shapeBBoxAbs=list(list(m1shapeBBoxLeft m1shapeBBoxBottom) list(m1shapeBBoxRight m1shapeBBoxTop))
										instList2=dbGetTrueOverlaps(cvLay1 m1shapeBBoxAbs nil)
										stdViaList=setof(x instList2 (x~>objType=="stdVia" && x~>net~>name==gateTerm~>net~>name))
										
										;printf("stdvialist:%L\n",stdViaList)
										when(stdViaList
											printf("has stdViaList\n")
											stdVia1=car(setof(x stdViaList x~>viaHeader~>viaDefName==stdVia1defName))
											;printf("stdvia1:%s net:%s\n",stdVia1,stdVia1~>net~>name)
											m1pinCenterY=cadr(centerBox(m1pinBBoxAbs))
											m1pinCenterX=car(centerBox(m1pinBBoxAbs))
											stdVia1centerY=cadr(stdVia1~>xy)
											;printf("inst:%s m1pin:%f stdvia1:%f\n",inst~>name,m1pinCenterY,stdVia1centerY)
											delta=m1pinCenterY-stdVia1centerY
											when(abs(delta)>0.01
												;printf("inst:%s\n",inst~>name)
												;printf("Move stdvia1 by %f\n",delta)
												dbMoveFig(stdVia1 nil list(0:delta "R0"))
												
												stdVia2list=setof(x stdViaList x~>viaHeader~>viaDefName==stdVia2defName)
												stdVia2=car(stdVia2list)
												when(!stdVia2
													printf("no stdvia2\n")
													list1=dbGetTrueOverlaps(cvLay1 m1shapeBBoxAbs metal2layer)
													metal2path=car(setof(x list1 x~>net~>name==gateTerm~>net~>name))
													when(!metal2path printf("no metal2path\n"))
												
													instList3=dbGetTrueOverlaps(cvLay1 metal2path~>bBox nil)
													stdVia2=car(setof(x instList3 (x~>objType=="stdVia" && x~>viaHeader~>viaDefName==stdVia2defName && x~>net~>name==gateTerm~>net~>name)))
													when(!stdVia2
														error("No stdvia2\n")
													)
												)
												
												dbMoveFig(stdVia2 nil list(0:delta "R0"))
												
												stdVia2centerX=car(stdVia2~>xy)
												
												metal3pathCenter=m1pinCenterX-float(mod(round(m1pinCenterX*1000) round(trackSpacing[metal3layer]*1000)))/1000
												metal3pathLeft=metal3pathCenter-metal3minW/2
												metal3pathRight=metal3pathCenter+metal3minW/2
												;list1=dbGetTrueOverlaps(cvLay1 list(list(metal3pathLeft metal3pathBottom) list(metal3pathRight metal3pathTop)) metal3layer)
												;when(list1
												;	metal3pathCenter=metal3pathCenter+trackSpacing[metal3layer]
												;	metal3pathLeft=metal3pathCenter-metal3minW/2
												;	metal3pathRight=metal3pathCenter+metal3minW/2
												;)									
	
												delta2=metal3pathCenter-stdVia2centerX
												when(abs(delta2)>0.1
													dbMoveFig(stdVia2 nil list(delta2:0 "R0"))
												)
												
												m3shape=car(setof(shape dbGetTrueOverlaps(cvLay1 m1shapeBBoxAbs metal3layer) shape~>net~>name==gateTerm~>net~>name))
												flag1=nil
												if(m3shape then
													when(abs(car(centerBox(m3shape~>bBox))-metal3pathCenter)>0.1
														flag1=t
													)
												else
													flag1=t
												)
												
												;;To fix the gate routing problem where 2 abutted devices have the same gate net 
												when(flag1
													;error("Can't find M3 shape associated with gate pin of %s\n",inst~>name)
													m2shape=car(setof(shape dbGetTrueOverlaps(cvLay1 m1shapeBBoxAbs metal2layer) shape~>net~>name==gateTerm~>net~>name))
													m3shape=car(setof(shape dbGetTrueOverlaps(cvLay1 m2shape~>bBox metal3layer) shape~>net~>name==gateTerm~>net~>name))
													m4shape=car(setof(shape dbGetTrueOverlaps(cvLay1 m3shape~>bBox metal4layer) shape~>net~>name==gateTerm~>net~>name))
													list1=dbGetTrueOverlaps(cvLay1 m3shape~>bBox nil)
													stdVia3=car(setof(x list1 x~>viaHeader~>viaDefName==stdVia3defName))
													dbMoveFig(m3shape nil list(delta2:0 "R0"))
													dbMoveFig(stdVia3 nil list(delta2:0 "R0"))
													stdVia3centerX=car(stdVia3~>xy)
													m4shapeBeginPtX=car(m4shape~>beginPt)
													m4shapeEndPtX=car(m4shape~>endPt)
													if(abs(stdVia3centerX-m4shapeBeginPtX)<abs(stdVia3centerX-m4shapeEndPtX) then
														m4shape~>beginPt=list(m4shapeBeginPtX+delta2 cadr(m4shape~>beginPt))
													else
														m4shape~>endPt=list(m4shapeEndPtX+delta2 cadr(m4shape~>endPt))
													)
												)
												
												;printf("m3shape:%s %s\n",m3shape,m3shape~>objType)
												m3shapeBeginPtY=cadr(m3shape~>beginPt)
												m3shapeEndPtY=cadr(m3shape~>endPt)
												when(m1pinCenterY>m3shapeBeginPtY && m1pinCenterY>m3shapeEndPtY
													if((m1pinCenterY-m3shapeBeginPtY)<(m1pinCenterY-m3shapeEndPtY) then
														m3shape~>beginPt=list(car(m3shape~>beginPt) m3shapeBeginPtY+delta)
													else	
														m3shape~>endPt=list(car(m3shape~>endPt) m3shapeEndPtY+delta)
													)
												)
												when(m1pinCenterY<m3shapeBeginPtY && m1pinCenterY<m3shapeEndPtY
													if((m3shapeBeginPtY-m1pinCenterY)<(m3shapeEndPtY-m1pinCenterY) then
														m3shape~>beginPt=list(car(m3shape~>beginPt) m3shapeBeginPtY+delta)
													else	
														m3shape~>endPt=list(car(m3shape~>endPt) m3shapeEndPtY+delta)
													)
												)
												
												foreach(m1shape m1shapeList
													when(!listp(m1shape) && (getBBoxTop(m1shape)-getBBoxBottom(m1shape))>metal1minW
														dbDeleteObject(m1shape)
													)
												)
												
												m2shapeList=setof(shape dbGetTrueOverlaps(cvLay1 m1shapeBBoxAbs metal2layer) shape~>net~>name==gateTerm~>net~>name)
												foreach(m2shape m2shapeList
													when(!listp(m2shape)
														dbDeleteObject(m2shape)
													)
												)
											)
											
											;m3shape=car(setof(shape dbGetTrueOverlaps(cvLay1 m1shapeBBoxAbs metal3layer) shape~>net~>name==gateTerm~>net~>name))
											;instList=dbGetTrueOverlaps(cvLay1 m3shape~>bBox nil)
											;stdViaList=setof(x instList (x~>objType=="stdVia" && x~>net~>name==gateTerm~>net~>name))
											;stdVia2list=setof(x stdViaList x~>viaHeader~>viaDefName==stdVia2defName)
											
											m1pinCenterX=car(centerBox(m1pinBBoxAbs))
											stdVia1centerX=car(stdVia1~>xy)
											delta=m1pinCenterX-stdVia1centerX
											when(abs(delta)>0.01
												;printf("moving stdvia1 horizontally for %s\n",inst~>name)
												dbMoveFig(stdVia1 nil list(delta:0 "R0"))
												m2shape=car(setof(shape dbGetTrueOverlaps(cvLay1 m1shapeBBoxAbs metal2layer) shape~>net~>name==gateTerm~>net~>name))
												when(m2shape
													dbDeleteObject(m2shape)
												)
											)
											
											;;Connect gate pin to metal4
											;;Only for situations where 2 abutted devices have the same gate net and the script has moved the gate pin connection to 1 of the devices
											instList2=dbGetTrueOverlaps(cvLay1 m1pinBBoxAbs nil)
											stdViaList=setof(x instList2 (x~>objType=="stdVia" && x~>net~>name==gateTerm~>net~>name))
											stdVia2=car(setof(x stdViaList x~>viaHeader~>viaDefName==stdVia2defName))
											flag1=nil
											if(stdVia2 then
												printf("has stdvia2:%L\n",stdVia2~>bBox)
												printf("m1pinBBoxAbs:%L\n",m1pinBBoxAbs)
												stdVia2centerX=car(stdVia2~>xy)
												;when(abs(m1pinCenterX-stdVia2centerX)>0.2
												when(stdVia2centerX<bBoxLeft(m1pinBBoxAbs) || stdVia2centerX>bBoxRight(m1pinBBoxAbs)
													printf("false stdvia2\n")
													flag1=t
												)
											else
												printf("no stdvia2:%s\n",inst~>name)
												flag1=t
											)
											when(flag1 && !member(inst~>name instListGateConnected)
												printf("connecting gate pin to metal4\n")
												printf("%L\n",instListGateConnected)
												instListGateConnected=append(instListGateConnected list(inst~>name))
												m4shape=car(setof(x cvLay1~>shapes (x~>layerName==metal4layer)&&(x~>net~>name==gateTerm~>net~>name)))
												;printf("m4shape:%L\n",m4shape~>bBox)
												m4shapeCenterY=cadr(centerBox(m4shape~>bBox))
												
												if(m1pinCenterY>m4shapeCenterY then
													metal3pathTop=m1pinCenterY
													metal3pathBottom=bBoxTop(m4shape~>bBox)
												else
													metal3pathTop=bBoxBottom(m4shape~>bBox)
													metal3pathBottom=m1pinCenterY
												)
												
												metal3pathCenter=m1pinCenterX-float(mod(round(m1pinCenterX*1000) round(trackSpacing[metal3layer]*1000)))/1000
												metal3pathLeft=metal3pathCenter-metal3minW/2
												metal3pathRight=metal3pathCenter+metal3minW/2
												list1=dbGetTrueOverlaps(cvLay1 list(list(metal3pathLeft metal3pathBottom) list(metal3pathRight metal3pathTop)) metal3layer)
												when(list1
													metal3pathCenter=metal3pathCenter+trackSpacing[metal3layer]
													metal3pathLeft=metal3pathCenter-metal3minW/2
													metal3pathRight=metal3pathCenter+metal3minW/2
												)
												leCreatePath(cvLay1 list(metal3layer "drawing") list(metal3pathCenter:metal3pathTop metal3pathCenter:metal3pathBottom) metal3minW)
												dbCreateVia(cvLay1 stdVia2def list(metal3pathCenter m1pinCenterY) "R0" list(list("layer1Enc" list(stdVia2layer1Enc 0))))
												dbCreateVia(cvLay1 stdVia3def list(metal3pathCenter m4shapeCenterY) "R0" list(list("layer2Enc" list(stdVia3layer2Enc stdVia3layer2Enc))))
											)
										)
									)
								)
							)
						);;Align V1 to gate pin
					);;when there are nets to route
			    );;For each prioirty group
			else	
				printf("Routing %L\n",routeNets)
				hsmSelect(?type 'net ?name routeNets)
				poport=outPort
	      		woport=outPort
	      		errport=outPort
				_iaAutomaticExecuteCmd('autoRoute stringToSymbol("selected"))
				poport=stdout
	      		errport=stderr
	      		woport=stdout
				hsmDeselect(?type 'net ?name routeNets)
			)
			close(outPort)
		);;When route
		
		;;Fix stdvia1 positions and metal2 top/bottom enclosures
		stdVia1list=setof(x cvLay1~>vias x~>viaHeader~>viaDefName==stdVia1defName)
		foreach(stdVia1 stdVia1list
			centerX=car(stdVia1~>origin)
			centerY=cadr(stdVia1~>origin)
			foreach(track m2wspAbs
				delta=centerY-track
				when(abs(delta)>0.001 && abs(delta)<0.02
					printf("stdvia1 off track:%f %f\n",centerY,track)
					dbDeleteObject(stdVia1)
					dbCreateVia(cvLay1 stdVia1def list(centerX track) "R0" list(list("layer1Enc" list(0 0.015)) list("layer2Enc" list(0.025 0))))
				)
			)
		)
		
		;;Delete redundant stdvia2s
		stdVia2list=setof(x cvLay1~>vias x~>viaHeader~>viaDefName==stdVia2defName)
		foreach(stdVia2 stdVia2list
			metal2shapes=dbGetTrueOverlaps(cvLay1 stdVia2~>bBox metal2layer)
			when(metal2shapes
				;printf("metal2shapes:%L\n",metal2shapes)
				metal2shape=car(metal2shapes)
				instList=dbGetTrueOverlaps(cvLay1 metal2shape~>bBox nil)
				stdViaList=setof(x instList x~>objType=="stdVia")
				;printf("stdViaList:%L\n",stdViaList)
				flag1=t
				foreach(stdVia stdViaList
					when(getBBoxLeft(stdVia)!=getBBoxLeft(stdVia2)
						flag1=nil
					)
				)
				when(flag1
					printf("deleting stdvia2 %L\n",stdVia2~>bBox)
					dbDeleteObject(stdVia2)
				)
			)
		)
		
		;;Delete redundant metal2 shapes
		metal2shapes=setof(x cvLay1~>shapes (car(x~>lpp)==metal2layer && cadr(x~>lpp)=="drawing"))
		foreach(metal2shape metal2shapes
			instList=dbGetTrueOverlaps(cvLay1 metal2shape~>bBox nil)
			stdViaList=setof(x instList x~>objType=="stdVia")
			via1list=dbGetTrueOverlaps(cvLay1 metal2shape~>bBox via1layer)
			when(length(stdViaList)==0 && length(via1list)==0
				dbDeleteObject(metal2shape)
			)
		)
		
		;;Delete redundant stdvia3 shapes
		stdViaList=setof(x cvLay1~>vias x~>objType=="stdVia")
		stdVia3list=setof(x stdViaList x~>viaHeader~>viaDefName==stdVia3defName)
		foreach(stdVia3 stdVia3list
			metal4shapes=dbGetTrueOverlaps(cvLay1 stdVia3~>bBox metal4layer)
			when(length(metal4shapes)==0
				dbDeleteObject(stdVia3)
			)
		)
		
		;;Restore M1 gate pin length
		printstruct(gatePinModificationTable)
		foreach(m1GatePin gatePinModificationTable
			float1=gatePinModificationTable[m1GatePin]
			bBoxLeft=getBBoxLeft(m1GatePin)+float1
			bBoxRight=getBBoxRight(m1GatePin)-float1
			bBoxBottom=getBBoxBottom(m1GatePin)
			bBoxTop=getBBoxTop(m1GatePin)
			m1GatePin~>bBox=list(list(bBoxLeft bBoxBottom) list(bBoxRight bBoxTop))
		)
		
		;;Extend M1 gate pin and corresponding M2 shape for 1- or 2-finger dev
		for(i 1 numofRows
			foreach(inst generatedRowInstTable[i]
				printf("inst:%s\n",inst~>name)
				when(get(inst polyContTopParam)==polyContTopTrue || get(inst polyContBottomParam)==polyContBottomTrue
					numofFingers=get(inst numofFingersParam)
					when(stringp(numofFingers) numofFingers=atoi(numofFingers))
					when(numofFingers && numofFingers<=2
						gateTerm=car(setof(term inst~>instTerms rexMatchp(gateTermMatchName term~>name)))
						fig=car(gateTerm~>term~>pins)~>fig
						bBox=dbTransformBBox(fig~>bBox dbGetInstTransform(list(inst)))
						shapeLeft=bBoxLeft(bBox)-0.05
						shapeRight=bBoxRight(bBox)+0.05
						shapeBottom=bBoxBottom(bBox)
						shapeTop=bBoxTop(bBox)
						dbCreateRect(cvLay1 list(metal1layer "drawing") list(shapeLeft:shapeBottom shapeRight:shapeTop))
						dbCreateRect(cvLay1 list(metal2layer "drawing") list(shapeLeft:shapeBottom shapeRight:shapeTop))
					)
				)
			)
		)
		
		lxUpdateBinding(cvLay1 ?schCV cvSch)
		shortMarkerList=lceGetShortMarkers()
		when(shortMarkerList warn("There are shorts in the layout\n"))
		
		;;Create poly-cut layer and extend poly where necessary
		for(i 1 numofRows
			bBoxTopMost=-1000
			bBoxBottomMost=1000
			foreach(inst generatedRowInstTable[i]
				when(member(inst~>cellName fetList)
					list1=dbGetTrueOverlaps(cvLay1 inst~>bBox polyCutLayer 0:1)
					foreach(element list1
						if(listp(element) then
							inst2=car(element)
							shape=cadr(element)
							bBox=dbTransformBBox(shape~>bBox dbGetInstTransform(list(inst2)))
						else
							shape=element
							bBox=shape~>bBox
						)
						bBoxTop=bBoxTop(bBox)
						bBoxBottom=bBoxBottom(bBox)
						when(bBoxTop>bBoxTopMost bBoxTopMost=bBoxTop)
						when(bBoxBottom<bBoxBottomMost bBoxBottomMost=bBoxBottom)
					);;foreach polycut layer
				)
			);;foreach inst
			
			when(bBoxTopMost>-1000
				printf("row:%d bBoxTopMost:%f bBoxBottomMost:%f\n",i,bBoxTopMost,bBoxBottomMost)
				shapeTop=bBoxTopMost
				shapeBottom=shapeTop-polyCutW
				polyCutShapeBottom=shapeBottom
				shapeLeft=getBBoxLeft(car(generatedRowInstTable[i]))
				when(get(car(generatedRowInstTable[i]) dummyPolyLeftParam)==dummyPolyLeftTrue
					shapeLeft=shapeLeft+0.248
				)
				shapeRight=getBBoxRight(car(last(generatedRowInstTable[i])))
				when(get(car(last(generatedRowInstTable[i])) dummyPolyRightParam)==dummyPolyRightTrue
					shapeRight=shapeRight-0.248
				)
				dbCreateRect(cvLay1 list(polyCutLayer "drawing") list(shapeLeft:shapeBottom shapeRight:shapeTop))
				
				shapeTop=shapeTop-polyCutEnclPoly
				foreach(inst generatedRowInstTable[i]
					shapeBottom=cadr(inst~>xy)
					numofFingers=get(inst numofFingersParam)
					when(stringp(numofFingers) numofFingers=atoi(numofFingers))
					when(get(inst dummyPolyLeftParam)==dummyPolyLeftTrue
						shapeLeft=car(inst~>xy)-polyPitch
						shapeRight=shapeLeft+polyMinW
						dbCreateRect(cvLay1 list(poly_layer "drawing") list(shapeLeft:shapeBottom shapeRight:shapeTop))
						dbCreateRect(cvLay1 list(auxPolyLayer "drawing") list(shapeLeft:shapeBottom shapeRight:polyCutShapeBottom))
						shapeLeft2=shapeLeft-(trenchSilicideBlockMinW-polyMinW)/2
						shapeRight=shapeLeft2+trenchSilicideBlockMinW
						dbCreateRect(cvLay1 list(trenchSilicideBlockLayer "drawing") list(shapeLeft2:shapeBottom shapeRight:shapeTop))
						shapeLeft=shapeLeft-polyPitch
						shapeRight=shapeLeft+polyMinW
						dbCreateRect(cvLay1 list(poly_layer "drawing") list(shapeLeft:shapeBottom shapeRight:shapeTop))
						shapeLeft2=shapeLeft-(trenchSilicideBlockMinW-polyMinW)/2
						shapeRight=shapeLeft2+trenchSilicideBlockMinW
						dbCreateRect(cvLay1 list(trenchSilicideBlockLayer "drawing") list(shapeLeft2:shapeBottom shapeRight:shapeTop))
					)
					when(get(inst dummyPolyRightParam)==dummyPolyRightTrue
						;printf("inst:%s %s:true\n",inst~>name,dummyPolyRightParam)
						shapeLeft=car(inst~>xy)+polyPitch*numofFingers
						shapeRight=shapeLeft+polyMinW
						dbCreateRect(cvLay1 list(poly_layer "drawing") list(shapeLeft:shapeBottom shapeRight:shapeTop))
						dbCreateRect(cvLay1 list(auxPolyLayer "drawing") list(shapeLeft:shapeBottom shapeRight:polyCutShapeBottom))
						shapeLeft2=shapeLeft-(trenchSilicideBlockMinW-polyMinW)/2
						shapeRight=shapeLeft2+trenchSilicideBlockMinW
						dbCreateRect(cvLay1 list(trenchSilicideBlockLayer "drawing") list(shapeLeft2:shapeBottom shapeRight:shapeTop))
						shapeLeft=shapeLeft+polyPitch
						shapeRight=shapeLeft+polyMinW
						dbCreateRect(cvLay1 list(poly_layer "drawing") list(shapeLeft:shapeBottom shapeRight:shapeTop))
						shapeLeft2=shapeLeft-(trenchSilicideBlockMinW-polyMinW)/2
						shapeRight=shapeLeft2+trenchSilicideBlockMinW
						dbCreateRect(cvLay1 list(trenchSilicideBlockLayer "drawing") list(shapeLeft2:shapeBottom shapeRight:shapeTop))
					)
					shapeLeft=car(inst~>xy)
					for(j 1 numofFingers
						shapeRight=shapeLeft+polyMinW
						dbCreateRect(cvLay1 list(poly_layer "drawing") list(shapeLeft:shapeBottom shapeRight:shapeTop))
						shapeLeft2=shapeLeft-(trenchSilicideBlockMinW-polyMinW)/2
						shapeRight=shapeLeft2+trenchSilicideBlockMinW
						dbCreateRect(cvLay1 list(trenchSilicideBlockLayer "drawing") list(shapeLeft2:shapeBottom shapeRight:shapeTop))
						shapeLeft=shapeLeft+polyPitch
					)
				)
			)
			
			when(bBoxBottomMost<1000
				printf("row:%d bBoxTopMost:%f bBoxBottomMost:%f\n",i,bBoxTopMost,bBoxBottomMost)
				shapeBottom=bBoxBottomMost
				shapeTop=shapeBottom+polyCutW
				polyCutShapeTop=shapeTop
				shapeLeft=getBBoxLeft(car(generatedRowInstTable[i]))
				when(get(car(generatedRowInstTable[i]) dummyPolyLeftParam)==dummyPolyLeftTrue
					shapeLeft=shapeLeft+0.248
				)
				shapeRight=getBBoxRight(car(last(generatedRowInstTable[i])))
				when(get(car(last(generatedRowInstTable[i])) dummyPolyRightParam)==dummyPolyRightTrue
					shapeRight=shapeRight-0.248
				)
				dbCreateRect(cvLay1 list(polyCutLayer "drawing") list(shapeLeft:shapeBottom shapeRight:shapeTop))
				
				shapeBottom=shapeBottom+polyCutEnclPoly
				foreach(inst generatedRowInstTable[i]
					shapeTop=cadr(inst~>xy)
					numofFingers=get(inst numofFingersParam)
					when(stringp(numofFingers) numofFingers=atoi(numofFingers))
					when(get(inst dummyPolyLeftParam)==dummyPolyLeftTrue
						shapeLeft=car(inst~>xy)-polyPitch
						shapeRight=shapeLeft+polyMinW
						dbCreateRect(cvLay1 list(poly_layer "drawing") list(shapeLeft:shapeBottom shapeRight:shapeTop))
						dbCreateRect(cvLay1 list(auxPolyLayer "drawing") list(shapeLeft:polyCutShapeTop shapeRight:shapeTop))
						shapeLeft2=shapeLeft-(trenchSilicideBlockMinW-polyMinW)/2
						shapeRight=shapeLeft2+trenchSilicideBlockMinW
						dbCreateRect(cvLay1 list(trenchSilicideBlockLayer "drawing") list(shapeLeft2:shapeBottom shapeRight:shapeTop))
						shapeLeft=shapeLeft-polyPitch
						shapeRight=shapeLeft+polyMinW
						dbCreateRect(cvLay1 list(poly_layer "drawing") list(shapeLeft:shapeBottom shapeRight:shapeTop))
						shapeLeft2=shapeLeft-(trenchSilicideBlockMinW-polyMinW)/2
						shapeRight=shapeLeft2+trenchSilicideBlockMinW
						dbCreateRect(cvLay1 list(trenchSilicideBlockLayer "drawing") list(shapeLeft2:shapeBottom shapeRight:shapeTop))
					)
					when(get(inst dummyPolyRightParam)==dummyPolyRightTrue
						shapeLeft=car(inst~>xy)+polyPitch*numofFingers
						shapeRight=shapeLeft+polyMinW
						dbCreateRect(cvLay1 list(poly_layer "drawing") list(shapeLeft:shapeBottom shapeRight:shapeTop))
						dbCreateRect(cvLay1 list(auxPolyLayer "drawing") list(shapeLeft:polyCutShapeTop shapeRight:shapeTop))
						shapeLeft2=shapeLeft-(trenchSilicideBlockMinW-polyMinW)/2
						shapeRight=shapeLeft2+trenchSilicideBlockMinW
						dbCreateRect(cvLay1 list(trenchSilicideBlockLayer "drawing") list(shapeLeft2:shapeBottom shapeRight:shapeTop))
						shapeLeft=shapeLeft+polyPitch
						shapeRight=shapeLeft+polyMinW
						dbCreateRect(cvLay1 list(poly_layer "drawing") list(shapeLeft:shapeBottom shapeRight:shapeTop))
						shapeLeft2=shapeLeft-(trenchSilicideBlockMinW-polyMinW)/2
						shapeRight=shapeLeft2+trenchSilicideBlockMinW
						dbCreateRect(cvLay1 list(trenchSilicideBlockLayer "drawing") list(shapeLeft2:shapeBottom shapeRight:shapeTop))
					)
					shapeLeft=car(inst~>xy)
					;numofFingers=get(inst numofFingersParam)
					;when(stringp(numofFingers) numofFingers=atoi(numofFingers))
					for(j 1 numofFingers
						shapeRight=shapeLeft+polyMinW
						dbCreateRect(cvLay1 list(poly_layer "drawing") list(shapeLeft:shapeBottom shapeRight:shapeTop))
						shapeLeft2=shapeLeft-(trenchSilicideBlockMinW-polyMinW)/2
						shapeRight=shapeLeft2+trenchSilicideBlockMinW
						dbCreateRect(cvLay1 list(trenchSilicideBlockLayer "drawing") list(shapeLeft2:shapeBottom shapeRight:shapeTop))
						shapeLeft=shapeLeft+polyPitch
					)
				)
			)
		);;foreach row
		
		;;Connect polys of adjacent rows that are close to each other
		;;Tap cell at bottom, FET array at top
		for(i 1 (numofRows-1)
			inst=car(generatedRowInstTable[i])
			inst2=car(generatedRowInstTable[i+1])
			pcPitch=get(inst2 fetPCpitchParam2)
			when(stringp(pcPitch) pcPitch=cdfParseFloatString(pcPitch)*1e6)
			when(inst~>cellName==tapCellName && member(inst2~>cellName fetList) && pcPitch<polyPitch+0.001
				printf("row %d:%s row %d:%s\n",i,inst~>name,i+1,inst2~>name)
				
				list1=dbGetTrueOverlaps(cvLay1 inst2~>bBox polyCutLayer)
				polyCutShapeBottom=1000
				foreach(shape list1
					when(getBBoxBottom(shape)<polyCutShapeBottom polyCutShapeBottom=getBBoxBottom(shape))
				)
				
				shapeBottom=cadr(inst~>xy)
				shapeTop=cadr(inst2~>xy)
				shapeCenter=car(inst~>xy)
				while(shapeCenter<(car(inst~>xy)+get(inst tapCellRXwidthParam)+0.001)
					shapeLeft=shapeCenter-polyMinW/2
					shapeRight=shapeLeft+polyMinW
					dbCreateRect(cvLay1 list(poly_layer "drawing") list(shapeLeft:shapeBottom shapeRight:shapeTop))
					dbCreateRect(cvLay1 list(auxPolyLayer "drawing") list(shapeLeft:shapeBottom shapeRight:polyCutShapeBottom))
					
					shapeLeft=shapeCenter-trenchSilicideBlockMinW/2
					shapeRight=shapeLeft+trenchSilicideBlockMinW
					dbCreateRect(cvLay1 list(trenchSilicideBlockLayer "drawing") list(shapeLeft:shapeBottom shapeRight:shapeTop))
					
					shapeCenter=shapeCenter+polyPitch
				)
			)
		);;foreach row
		
		;;Tap cell at top, FET array at bottom (WARNING: UNTESTED CODE)
		j=numofRows
		for(i 1 (numofRows-1)
			inst=car(generatedRowInstTable[j])
			inst2=car(generatedRowInstTable[j-1])
			pcPitch=get(inst2 fetPCpitchParam2)
			when(stringp(pcPitch) pcPitch=cdfParseFloatString(pcPitch)*1e6)
			when(inst~>cellName==tapCellName && member(inst2~>cellName fetList) && pcPitch<polyPitch+0.001
				printf("row %d:%s row %d:%s\n",j,inst~>name,j-1,inst2~>name)
				
				list1=dbGetTrueOverlaps(cvLay1 inst2~>bBox polyCutLayer)
				polyCutShapeTop=-1000
				foreach(shape list1
					when(getBBoxTop(shape)>polyCutShapeTop polyCutShapeTop=getBBoxTop(shape))
				)
				
				shapeBottom=cadr(inst2~>xy)
				shapeTop=cadr(inst~>xy)
				shapeCenter=car(inst~>xy)
				while(shapeCenter<(car(inst~>xy)+get(inst tapCellRXwidthParam)+0.001)
					shapeLeft=shapeCenter-polyMinW/2
					shapeRight=shapeLeft+polyMinW
					dbCreateRect(cvLay1 list(poly_layer "drawing") list(shapeLeft:shapeBottom shapeRight:shapeTop))
					dbCreateRect(cvLay1 list(auxPolyLayer "drawing") list(shapeLeft:polyCutShapeTop shapeRight:shapeTop))
					
					shapeLeft=shapeCenter-trenchSilicideBlockMinW/2
					shapeRight=shapeLeft+trenchSilicideBlockMinW
					dbCreateRect(cvLay1 list(trenchSilicideBlockLayer "drawing") list(shapeLeft:shapeBottom shapeRight:shapeTop))
					
					shapeCenter=shapeCenter+polyPitch
				)
			)
			j=j-1
		);;foreach row
		
		;;Dummy poly fill
		when(dummyPolyFill
			pwrRailNet=dbFindNetByName(cvLay1 pwrRailName)
			gndRailNet=dbFindNetByName(cvLay1 gndRailName)
			pwrGndshortMarkerList=lceGetShortMarkers(list(pwrRailNet gndRailNet))
			printf("pwrGndshortMarkerList before dummy poly fill:%L\n",pwrGndshortMarkerList)
			bBoxLeftMin=1000
			bBoxRightMax=0
			for(i 1 numofRows
				bBoxLeft=getBBoxLeft(car(generatedRowInstTable[i]))
				if(bBoxLeft<bBoxLeftMin then
					bBoxLeftMin=bBoxLeft
				)
				bBoxRight=getBBoxRight(car(last(generatedRowInstTable[i])))
				if(bBoxRight>bBoxRightMax then
					bBoxRightMax=bBoxRight
				)
			)
			shapeBottom=getBBoxBottom(car(generatedRowInstTable[1]))
			shapeTop=getBBoxTop(car(generatedRowInstTable[numofRows]))
			;printf("%f %f %f %f\n",bBoxLeftMin,bBoxRightMax,shapeBottom,shapeTop)
			num1=mod(int(bBoxLeftMin*1000) int(polyPitch*1000))
			shapeCenter=bBoxLeftMin+2*polyPitch-float(num1)/1000
			while(shapeCenter<(bBoxRightMax-polyPitch)
				shapeLeft=shapeCenter-polyMinW/2
				shapeRight=shapeCenter+polyMinW/2
				dbCreateRect(cvLay1 list(poly_layer "drawing") list(list(shapeLeft shapeBottom) list(shapeRight shapeTop)))
				shapeLeft=shapeCenter-trenchSilicideBlockMinW/2
				shapeRight=shapeCenter+trenchSilicideBlockMinW/2
				dbCreateRect(cvLay1 list(trenchSilicideBlockLayer "drawing") list(list(shapeLeft shapeBottom) list(shapeRight shapeTop)))
				shapeCenter=shapeCenter+polyPitch
			)
		)
		
		;;Create PR boundary to facilitate cell abuttment during hierarhical layout
		list1=getPlacementBoundary(cvLay1)
		dbCreateRect(cvLay1 list(prBoundaryLayer "drawing") list1)
		
		;;Write abut files
		outPort=outfile(strcat(cellName ".abutFile"))
		numofFinsPvalid=nil
		numofFinsNvalid=nil
		for(i 1 numofRows
			;instList=generatedRowInstTable[i]
			instList=list(car(generatedRowInstTable[i]) car(last(generatedRowInstTable[i])))
			leftInst=t
			foreach(inst instList
				when(member(inst~>cellName fetList)
					netName=car(setof(term inst~>instTerms rexMatchp(sourceTermMatchName term~>name)))~>net~>name
					when(!leftInst
						numofFingers=get(inst numofFingersParam)
						when(stringp(numofFingers) numofFingers=atoi(numofFingers))
						when(mod(numofFingers 2)==1
							netName=car(setof(term inst~>instTerms rexMatchp(drainTermMatchName term~>name)))~>net~>name
						)
					)
					fprintf(outPort "%s " netName)
					
					gateTerm=car(setof(term inst~>instTerms rexMatchp(gateTermMatchName term~>name)))
					gateTermCenterY=cadr(centerBox(car(gateTerm~>term~>pins)~>fig~>bBox))
					printf("inst:%s gateTermCenterY:%f\n",inst~>name,gateTermCenterY)
					gateTermPos="near"
					when(member(inst~>cellName pfetList)
						when(abs(gateTermCenterY)>gateTermPosThreshold gateTermPos="far")
						numofFinsP=get(inst numofFinsParam)
						numofFinsPvalid=t
					)
					when(member(inst~>cellName nfetList)
						numofFins=get(inst numofFinsParam)
						when(stringp(numofFins) numofFins=atoi(numofFins))
						delta=gateTermCenterY-((numofFins-1)*finPitch+finThickness)
						printf("delta:%f\n",delta)
						when(abs(delta)>gateTermPosThreshold gateTermPos="far")
						numofFinsN=get(inst numofFinsParam)
						numofFinsNvalid=t
					)
					printf("gateTermPos:%s\n",gateTermPos)
					fprintf(outPort "%s " gateTermPos)
				)
				leftInst=nil
			)
		)
		
		fprintf(outPort "%d ",totalNumofFingersMax)
		;if(mod(totalNumofFingersMax 2)==0 then
		;	fprintf(outPort "even ")
		;else
		;	fprintf(outPort "odd ")
		;)
		
		when(numofFinsPvalid && numofFinsNvalid
			fprintf(outPort "%s %s ",numofFinsP,numofFinsN)
		)
		
		close(outPort)
		
		foreach(shape cvLay1~>shapes dbDeletePropByName(shape "lxStickyNet"))
		foreach(route cvLay1~>routes dbDeletePropByName(route "lxStickyNet"))
		lxUpdateBinding(cvLay1 ?schCV cvSch)
		
		;;Delete pin guides
		when(deletePinGuides
			foreach(pinGuide pinGuideList
				dbDeleteObject(pinGuide)
			)
		)
		
		;;Create aux pwr/gnd pins
	    foreach(pin auxPwrGndPinTable~>?
	    		tapCellInstName=nth(0 auxPwrGndPinTable[pin])
	    		xOffset=nth(1 auxPwrGndPinTable[pin])
	    		yOffset=nth(2 auxPwrGndPinTable[pin])
	    		netName=nth(3 auxPwrGndPinTable[pin])
	    		tapCellInst=dbFindAnyInstByName(cvLay1 tapCellInstName)
	    		shapeLeft=car(tapCellInst~>xy)+xOffset
	    		shapeRight=shapeLeft+metal1minW
	    		shapeBottom=cadr(tapCellInst~>xy)+yOffset
	    		shapeTop=shapeBottom+metal1minW
	    		shape=dbCreateRect(cvLay1 list(metal1layer "pin") list(shapeLeft:shapeBottom shapeRight:shapeTop))
	    		printf("netName:%s\n",netName)
	    		net=dbFindNetByName(cvLay1 netName)
	    		printf("net:%s\n",net)
	    		;shape~>net=net
	    		dbCreatePin(net shape)
	    		label=dbCreateLabel(cvLay1 list(metal1layer "label") centerBox(shape~>bBox) netName "centerCenter" "R0" "roman" 0.05)
			leAttachFig(label shape)
	    )
	    lxUpdateBinding(cvLay1 ?schCV cvSch)
	    
	    foreach(inst cvSch~>instances
			when(rexMatchp(vncapMatchName inst~>cellName)
				printf("vncap:%s\n",inst~>name)
				str1=get(inst vncapBotLevParamRead)
				printf("%s\n",str1)
				str1=get(inst vncapTopLevParamRead)
				printf("%s\n",str1)
			)
		)
		
	    foreach(inst cvSch~>instances
			when(rexMatchp(vncapMatchName inst~>cellName)
				printf("vncap:%s\n",inst~>name)
				str1=get(inst vncapBotLevParamWrite)
				printf("%s\n",str1)
				str1=get(inst vncapTopLevParamWrite)
				printf("%s\n",str1)
				
				str1=get(inst "botlevGDS")
				printf("%s\n",str1)
				str1=get(inst "toplevGDS")
				printf("%s\n",str1)
			)
		)
		
		;;Delete short markers between pwr and gnd due to dummy poly fill (false shorts)
		;;Cause of false shorts: for 3 abutted single-finger dummy devices, the poly cont of the middle device is disabled,
		;;and a poly cont shape is drawn connecting the gates of the 3 devices. This causes connectivity to be passed down
		;;to the gates of the devices. If the same happens to the 3 dummy devices in the row above/below, then after dummy
		;;poly fill, the gates will be "connected" from Virtuoso's perspective. These are false shorts because the poly cut
		;;layer (e.g., CT in GF12LP) is always between the gates of the 2 rows.
		when(dummyPolyFill
			pwrGndshortMarkerList2=lceGetShortMarkers(list(pwrRailNet gndRailNet))
			printf("pwrGndshortMarkerList after dummy poly fill:%L\n",pwrGndshortMarkerList2)
			list1=setof(x pwrGndshortMarkerList2 !member(x shortMarkerList))
			foreach(object list1
				dbDeleteObject(object)
			)
		)
		
		list1=lceGetIncompleteNets(cvLay1)
		list2=setof(x list1 (x~>name!=pwrRailName && x~>name!=gndRailName))
		printf("incomplete nets:%L\n",list1~>name)
		when(list2 warn("Routing is incomplete:%L\n",list2~>name))
		
		dbSave(cvSch)
		dbClose(cvSch)
		dbSave(cvLay1)
		dbClose(cvLay1)
		
		printf("Completed execution of genAMSlayout()\n")
	)
)

procedure(internalRoute1(cvLay cvSch net)
	let(()
		netName=net~>name
		printf("internal route: %s\n",netName)
		;net=dbFindNetByName(cvLay netName)
		
		ioPinFig=car(net~>term~>pins)~>fig
		ioPinBBox=ioPinFig~>bBox
		ioPinCenterX=car(centerBox(ioPinBBox))
		ioPinCenterY=cadr(centerBox(ioPinBBox))
		printf("io:%f %f\n",ioPinCenterX,ioPinCenterY)
		
		instTerms=net~>instTerms
		instList=instTerms~>inst
		i=0
		metal4pathRight=getBBoxRight(ioPinFig)
		metal4pathLeft=getBBoxLeft(ioPinFig)
		tech=techGetTechFile(cvLay)
		stdVia1def=techFindViaDefByName(tech stdVia1defName)
		stdVia2def=techFindViaDefByName(tech stdVia2defName)
		stdVia3def=techFindViaDefByName(tech stdVia3defName)
		foreach(term instTerms~>term
			fig=car(term~>pins)~>fig
			bBox=dbTransformBBox(fig~>bBox dbGetInstTransform(list(nth(i instList))))
			i=i+1
			printf("inst term:%L\n",bBox)
			bBoxCenter=centerBox(bBox)
			bBoxCenterX=car(bBoxCenter)
			bBoxCenterY=cadr(bBoxCenter)
			bBoxRight=bBoxRight(bBox)
			bBoxLeft=bBoxLeft(bBox)
			;when(bBoxCenterX>metal4pathRight metal4pathRight=bBoxCenterX)
			;when(bBoxCenterX<metal4pathLeft metal4pathLeft=bBoxCenterX)
			;when(bBoxRight>metal4pathRight metal4pathRight=bBoxRight)
			;when(bBoxLeft<metal4pathLeft metal4pathLeft=bBoxLeft)
			
			cutRows=int(((bBoxRight(bBox)-bBoxLeft(bBox))-2*stdVia1layer2Enc)/(stdVia1minCutspacing+via1size))+1
			dbCreateVia(cvLay stdVia1def bBoxCenter "R90" list(list("cutRows" cutRows) list("cutSpacing" list(stdVia1minCutspacing stdVia1minCutspacing))))
			
			if(bBoxCenterY>ioPinCenterY then
				;metal3pathTop=bBoxCenterY
				;metal3pathBottom=ioPinCenterY
				metal3pathTop=bBoxCenterY+via3size/2+stdVia3layer1Enc
				metal3pathBottom=ioPinCenterY-via3size/2-stdVia3layer1Enc
			else
				metal3pathTop=ioPinCenterY+via3size/2+stdVia3layer1Enc
				metal3pathBottom=bBoxCenterY-via3size/2-stdVia3layer1Enc
			)
			/*
			metal3pathCenter=bBoxCenterX-float(mod(round(bBoxCenterX*1000) round(trackSpacing[metal3layer]*1000)))/1000
			metal3pathLeft=metal3pathCenter-metal3minW/2
			metal3pathRight=metal3pathCenter+metal3minW/2
			list1=dbGetTrueOverlaps(cvLay list(list(metal3pathLeft metal3pathBottom) list(metal3pathRight metal3pathTop)) metal3layer)
			when(list1
				metal3pathCenter=metal3pathCenter+trackSpacing[metal3layer]
				metal3pathLeft=metal3pathCenter-metal3minW/2
				metal3pathRight=metal3pathCenter+metal3minW/2
			)
			*/
			metal3pathCenter=snap(bBoxCenterX trackSpacing[metal3layer] ?direction "left")
			metal3pathCenter=findTrack(cvLay metal3pathCenter (metal3pathBottom-lineEndSpacing[metal3layer]+0.001) (metal3pathTop+lineEndSpacing[metal3layer]-0.001) "vertical" trackSpacing[metal3layer] trackWidth[metal3layer] metal3layer net "both")
			;when(metal3pathCenter>metal4pathRight metal4pathRight=metal3pathCenter)
			;when(metal3pathCenter<metal4pathLeft metal4pathLeft=metal3pathCenter)
			metal3pathCenterFirst=metal3pathCenter
			while(metal3pathCenter>bBoxLeft
				when(metal3pathCenter<metal4pathLeft metal4pathLeft=metal3pathCenter)
				
				metal3pathLeft=metal3pathCenter-metal3minW/2
				metal3pathRight=metal3pathCenter+metal3minW/2
				leCreatePath(cvLay list(metal3layer "drawing") list(metal3pathCenter:metal3pathTop metal3pathCenter:metal3pathBottom) metal3minW)
				dbCreateVia(cvLay stdVia2def list(metal3pathCenter bBoxCenterY) "R0" list(list("layer1Enc" list(stdVia2layer1Enc 0))))
				dbCreateVia(cvLay stdVia3def list(metal3pathCenter ioPinCenterY) "R0" list(list("layer2Enc" list(stdVia3layer2Enc 0))))
				
				metal3pathCenter=metal3pathCenter-meshSpacing[metal3layer]
				metal3pathCenter=findTrack(cvLay metal3pathCenter (metal3pathBottom-lineEndSpacing[metal3layer]+0.001) (metal3pathTop+lineEndSpacing[metal3layer]-0.001) "vertical" trackSpacing[metal3layer] trackWidth[metal3layer] metal3layer net "both")
			)
			metal3pathCenter=metal3pathCenterFirst+meshSpacing[metal3layer]
			while(metal3pathCenter<bBoxRight
				when(metal3pathCenter>metal4pathRight metal4pathRight=metal3pathCenter)
				
				metal3pathLeft=metal3pathCenter-metal3minW/2
				metal3pathRight=metal3pathCenter+metal3minW/2
				leCreatePath(cvLay list(metal3layer "drawing") list(metal3pathCenter:metal3pathTop metal3pathCenter:metal3pathBottom) metal3minW)
				dbCreateVia(cvLay stdVia2def list(metal3pathCenter bBoxCenterY) "R0" list(list("layer1Enc" list(stdVia2layer1Enc 0))))
				dbCreateVia(cvLay stdVia3def list(metal3pathCenter ioPinCenterY) "R0" list(list("layer2Enc" list(stdVia3layer2Enc 0))))
				
				metal3pathCenter=metal3pathCenter+meshSpacing[metal3layer]
				metal3pathCenter=findTrack(cvLay metal3pathCenter (metal3pathBottom-lineEndSpacing[metal3layer]+0.001) (metal3pathTop+lineEndSpacing[metal3layer]-0.001) "vertical" trackSpacing[metal3layer] trackWidth[metal3layer] metal3layer net "both")
			)	
		)
		
		metal4pathLeft=metal4pathLeft-stdVia3layer2Enc-via3size/2
		metal4pathRight=metal4pathRight+stdVia3layer2Enc+via3size/2
		leCreatePath(cvLay list(metal4layer "drawing") list(metal4pathLeft:ioPinCenterY metal4pathRight:ioPinCenterY) metal4minW)
	);;let
);;procedure

procedure(internalRoute2(cvLay cvSch net)
	let((ioPinFig ioPinBBox ioPinCenterX ioPinCenterY 
		 instTerms instList
		 term fig bBox bBoxLeft bBoxLeftMost bBoxRight bBoxRightMost bBoxCenterX
		 instTermBottomTable instTermBottom instTermBottomList instTermBottom2 instTermBottomList2
		 instTermList instTerm inst instTop instBottom
		 shapeBottom shapeTop shapeLeft shapeRight shapeCenterX
		 instTermHoriBoundaryTable instTermHoriConnectTable
		 i)
		ioPinFig=car(net~>term~>pins)~>fig
		ioPinBBox=ioPinFig~>bBox
		ioPinCenterX=car(centerBox(ioPinBBox))
		ioPinCenterY=cadr(centerBox(ioPinBBox))
		;printf("io:%f %f\n",ioPinCenterX,ioPinCenterY)
		
		instTerms=net~>instTerms
		instList=instTerms~>inst
		instTermBottomTable=makeTable("instTermBottomTable")
		i=0
		foreach(term instTerms~>term
			fig=car(term~>pins)~>fig
			bBox=dbTransformBBox(fig~>bBox dbGetInstTransform(list(nth(i instList))))
			instTermBottom=int(bBoxBottom(bBox)*1000)
			when(!member(instTermBottom instTermBottomTable~>?) instTermBottomTable[instTermBottom]=list())
			instTermBottomTable[instTermBottom]=append(instTermBottomTable[instTermBottom] list(nth(i instTerms)))
			i=i+1
		)
		printstruct(instTermBottomTable)
		
		vncapTermOnNet=nil
		instTermHoriBoundaryTable=makeTable("instTermHoriBoundaryTable")
		instTermHoriConnectTable=makeTable("instTermHoriConnectTable")
		foreach(instTermBottom instTermBottomTable
			instTermList=instTermBottomTable[instTermBottom]
			;printf("%d:%L\n",instTermBottom,instTermList)
			;;Source/drain term row
			when(rexMatchp(sourceTermMatchName car(instTermList)~>name) || rexMatchp(drainTermMatchName car(instTermList)~>name)
				printf("source/drain terms at %d\n",instTermBottom)
				bBoxLeftMost=1000
				bBoxRightMost=-1000
				foreach(instTerm instTermList
					fig=car(instTerm~>term~>pins)~>fig
					bBox=dbTransformBBox(fig~>bBox dbGetInstTransform(list(instTerm~>inst)))
					bBoxLeft=bBoxLeft(bBox)
					bBoxRight=bBoxRight(bBox)
					;printf("left:%f\n",bBoxLeft)
					when(bBoxLeft<bBoxLeftMost bBoxLeftMost=bBoxLeft)
					when(bBoxRight>bBoxRightMost bBoxRightMost=bBoxRight)
				)
				printf("leftmost:%f rightmost:%f\n",bBoxLeftMost,bBoxRightMost)
				instTermHoriBoundaryTable[instTermBottom]=list(bBoxLeftMost bBoxRightMost)
				
				;;Create metal2 trunk
				if(ioPinFig && ioPinFig~>layerName==metal2layer then
					shapeBottom=ioPinCenterY-metal2minW/2
					shapeTop=ioPinCenterY+metal2minW/2
				else
					;shapeBottom=cadr(car(instTermList)~>inst~>xy)-(finPitch-finThickness)/2+metal2minPitch+metal2minPitchExtra
					sourceTermBBox=car(car(instTermList)~>term~>pins)~>fig~>bBox
					printf("sourceTermBBox:%L\n",sourceTermBBox)
					sourceTermBBoxBottom=bBoxBottom(sourceTermBBox)
					sourceTermBBoxTop=bBoxTop(sourceTermBBox)				
					shapeBottom=cadr(car(instTermList)~>inst~>xy)+sourceTermBBoxBottom+stdVia1layer1Enc
					shapeTop=shapeBottom+metal2minW
				)
				
				shapeLeft=bBoxLeftMost-stdVia1layer2Enc
				shapeRight=bBoxRightMost+stdVia1layer2Enc
				while(dbGetTrueOverlaps(cvLay list(list(shapeLeft shapeBottom) list(shapeRight shapeTop)) metal2layer)
					shapeBottom=shapeBottom+metal2minPitch+metal2minPitchExtra
					shapeTop=shapeBottom+metal2minW
				)
				
				printf("shapeLeft:%f shapeBottom:%f shapeRight:%f shapeTop:%f\n",shapeLeft,shapeBottom,shapeRight,shapeTop)
				dbCreateRect(cvLay list(metal2layer "drawing") list(shapeLeft:shapeBottom shapeRight:shapeTop))
				instTermHoriConnectTable[instTermBottom]=shapeBottom
				
				;;Create via1's
				foreach(instTerm instTermList
					fig=car(instTerm~>term~>pins)~>fig
					bBox=dbTransformBBox(fig~>bBox dbGetInstTransform(list(instTerm~>inst)))
					shapeLeft=bBoxLeft(bBox)
					shapeRight=bBoxRight(bBox)
					dbCreateRect(cvLay list(via1layer "drawing") list(shapeLeft:shapeBottom shapeRight:shapeTop))
				)
				
;; 				if(ioPinFig then
;; 					if(ioPinCenterX>bBoxLeft && bBoxLeft<bBoxRight then
;; 						if(car(ioPinFig~>lpp)==metal3layer then
;; 							shapeLeft=bBoxLeft(ioPinFig~>bBox)
;; 							shapeRight=bBoxRight(ioPinFig~>bBox)
;; 							dbCreateRect(cvLay list(via2layer "drawing") list(shapeLeft:shapeBottom shapeRight:shapeTop))
;; 							if(bBoxBottom(ioPinFig~>bBox)<shapeBottom then
;; 								shapeBottom=bBoxBottom(ioPinFig~>bBox)
;; 								shapeTop=shapeTop+stdVia2layer2Enc
;; 							else
;; 								shapeTop=bBoxTop(ioPinFig~>bBox)
;; 								shapeBottom=shapeBottom-stdVia2layer2Enc
;; 							)
;; 							dbCreateRect(cvLay list(metal3layer "drawing") list(shapeLeft:shapeBottom shapeRight:shapeTop))
;; 						else
;; 							error("Internal routing is only supported when IO pin is on metal3\n")
;; 						)
;; 					else
;; 						error("Internal routing is only supported when IO pin is bounded horizontally by metal2 trunk\n")
;; 					)
;; 				else
;; 					error("Internal routing is only supported when IO pin exists on net\n")
;; 				)
			);;Source/drain term row
			
			;;VNCAP term row
			when(rexMatchp(vncapMatchName car(instTermList)~>inst~>cellName)
				printf("VNCAP terms at %d\n",instTermBottom)
				inst=car(instTermList)~>inst
				vncapTermOnNet=t
				vncapInst=inst
				when(lindex(metalLayerList metal3layer)<lindex(metalLayerList get(inst vncapBotLevParamRead)) || 
					 lindex(metalLayerList metal3layer)>lindex(metalLayerList get(inst vncapTopLevParamRead))
					error("Internal routing is only supported for VNCAPs that include metal3\n")
				)
				
				instTermHoriBoundaryTable[instTermBottom]=list()
				foreach(instTerm instTermList
					fig=car(instTerm~>term~>pins)~>fig
					;fig~>lpp=list("M3" "drawing")
					bBox=dbTransformBBox(fig~>bBox dbGetInstTransform(list(instTerm~>inst)))
					bBoxLeft=bBoxLeft(bBox)
					bBoxRight=bBoxRight(bBox)
					bBoxCenterX=car(centerBox(bBox))
					printf("pin center x:%f\n",bBoxCenterX)
					instTermHoriBoundaryTable[instTermBottom]=append(instTermHoriBoundaryTable[instTermBottom] list(bBoxLeft bBoxRight))
					
					instTermHoriConnectTable[instTermBottom]=bBoxBottom(bBox)
					
;; 					if(ioPinFig then
;; 						if(ioPinCenterX>bBoxLeft && bBoxLeft<bBoxRight then
;; 							if(car(ioPinFig~>lpp)==metal3layer then
;; 								shapeLeft=bBoxLeft(ioPinFig~>bBox)
;; 								shapeRight=bBoxRight(ioPinFig~>bBox)
;; 								if(bBoxBottom(ioPinFig~>bBox)<bBoxBottom(bBox) then
;; 									shapeBottom=bBoxBottom(ioPinFig~>bBox)
;; 									shapeTop=cadr(centerBox(bBox))
;; 								else
;; 									shapeTop=bBoxTop(ioPinFig~>bBox)
;; 									shapeBottom=cadr(centerBox(bBox))
;; 								)
;; 								dbCreateRect(cvLay list(metal3layer "drawing") list(shapeLeft:shapeBottom shapeRight:shapeTop))
;; 							else
;; 								error("Internal routing is only supported for VNCAPs when IO pin is on metal3\n")
;; 							)
;; 						else
;; 							error("Internal routing is only supported for VNCAPs when IO pin is bounded horizontally by VNCAP pin\n")
;; 						)
;; 					else
;; 						error("Internal routing is only supported for VNCAPs when IO pin exists on net\n")
;; 					)
				)
			);;VNCAP term row
		);;For each term row
		printstruct(instTermHoriBoundaryTable)
		
		pinFigList=setof(x cvLay~>shapes x~>purpose=="pin" && x~>net==net)
		printf("pinFigList:%L\n",pinFigList~>net~>name)
		
		instTermBottomList=sort(instTermHoriBoundaryTable~>? 'lessp)
		for(i 0 length(instTermBottomList)-2
			instTermBottom=nth(i instTermBottomList)
			printf("%d %L\n",instTermBottom,instTermHoriBoundaryTable[instTermBottom])
			instTermList=instTermBottomTable[instTermBottom]
			instTop=bBoxTop(car(instTermList)~>inst~>bBox)
			printf("instTop:%f\n",instTop)
			
			instTermBottom2=nth((i+1) instTermBottomList)
			instTermList2=instTermBottomTable[instTermBottom2]
			;printf("%L\n",instTermList2)
			instBottom=bBoxBottom(car(instTermList2)~>inst~>bBox)
			printf("instBottom:%f\n",instBottom)
			
			;;Create horizontal metal4 trunk
			shapeLeft=car(instTermHoriBoundaryTable[instTermBottom])
			when(car(instTermHoriBoundaryTable[instTermBottom])>car(instTermHoriBoundaryTable[instTermBottom2])
				shapeLeft=car(instTermHoriBoundaryTable[instTermBottom2])
			)
			shapeRight=cadr(instTermHoriBoundaryTable[instTermBottom])
			when(cadr(instTermHoriBoundaryTable[instTermBottom])<cadr(instTermHoriBoundaryTable[instTermBottom2])
				shapeRight=cadr(instTermHoriBoundaryTable[instTermBottom2])
			)
			printf("shapeLeft:%f shapeRight:%f\n",shapeLeft,shapeRight)
			
			vncap=nil
			when(rexMatchp(vncapMatchName car(instTermBottomTable[instTermBottom])~>inst~>cellName) || rexMatchp(vncapMatchName car(instTermBottomTable[instTermBottom2])~>inst~>cellName)
				vncap=t
			)
			
			if(ioPinFig && ioPinCenterY>bBoxBottom(car(instTermList)~>inst~>bBox) && ioPinCenterY<bBoxTop(car(instTermList2)~>inst~>bBox) then
				printf("ioPinCenterY:%f\n",ioPinCenterY)
				metal4shapeCenterY=ioPinCenterY
				when(ioPinCenterX<shapeLeft shapeLeft=bBoxLeft(ioPinBBox))
				when(ioPinCenterX>shapeRight shapeRight=bBoxRight(ioPinBBox))
			else
				flag1=t
				foreach(pinFig pinFigList
					pinFigCenterY=cadr(centerBox(pinFig~>bBox))
					pinFigCenterX=car(centerBox(pinFig~>bBox))
					printf("pinFigCenterY:%f\n",pinFigCenterY)
					when(pinFigCenterY>getBBoxBottom(car(instTermList)~>inst) && pinFigCenterY<getBBoxTop(car(instTermList2)~>inst)
						printf("found pinFig\n")
						flag1=nil
						metal4shapeCenterY=pinFigCenterY
						when(pinFigCenterX<shapeLeft shapeLeft=getBBoxLeft(pinFig))
						when(pinFigCenterX>shapeRight shapeRight=getBBoxRight(pinFig))
					)
				)
				when(flag1
					metal4shapeCenterY=(instTop+instBottom)/2
					metal4shapeCenterY=snap(metal4shapeCenterY trackSpacing[metal4layer] ?direction "bottom")
				)
			)
			printf("	metal4shapeCenterY:%f\n",metal4shapeCenterY)

			metal4width=trackWidth[metal4layer]
			when(vncap metal4width=metal4wideW)
			;metal4shapeCenterY=findTrack(cvLay metal4shapeCenterY (shapeLeft-edgeSpacing[metal4layer]) (shapeRight+edgeSpacing[metal4layer]) "horizontal" trackSpacing[metal4layer] (metal4width+2*(trackSpacing[metal4layer]-trackWidth[metal4layer])) metal4layer net "both")
			metal4shapeCenterY=findTrack(cvLay metal4shapeCenterY (shapeLeft-edgeSpacing[metal4layer]) (shapeRight+edgeSpacing[metal4layer]) "horizontal" trackSpacing[metal4layer] (metal4width+edgeSpacing[metal4layer]) metal4layer net "both")
			printf("	metal4shapeCenterY:%f\n",metal4shapeCenterY)
			metal4shapeBottom=metal4shapeCenterY-metal4width/2
			metal4shapeTop=metal4shapeBottom+metal4width
			dbCreateRect(cvLay list(metal4layer "drawing") list(shapeLeft:metal4shapeBottom shapeRight:metal4shapeTop))
			
			;;Create vertical metal3 trunks from metal4 trunk to terms below (towards left)
			routeToVNCAPtopTerm=nil
			instTerm=car(instTermBottomTable[instTermBottom])
			when(rexMatchp(vncapMatchName instTerm~>inst~>cellName)
				printf("vncap inst term:%s\n",instTerm~>name)
				inst=instTerm~>inst
				instOrient=inst~>orient
				cond(
					(instOrient=="R0"
						cond(
							(vncapTopTerm==instTerm~>name
								printf("vncapTopTerm\n")
								routeToVNCAPtopTerm=t
							)
							(vncapLeftTerm==instTerm~>name
								printf("vncapLeftTerm\n")
								shapeLeft=getBBoxLeft(inst)
								shapeRight=shapeLeft+vncapTermWidth
								shapeTop=metal4shapeBottom
								shapeBottom=getBBoxTop(inst)
								when(dbGetTrueOverlaps(cvLay list(shapeLeft:shapeBottom+0.001 shapeRight:shapeTop-0.001) metal4layer)
									error("Unable to route net %s to %s\n",net~>name,inst~>name)
								)
								dbCreateRect(cvLay list(metal4layer "drawing") list(shapeLeft:shapeBottom shapeRight:shapeTop))
							)
							(vncapRightTerm==instTerm~>name
								printf("vncapRightTerm\n")
								shapeRight=getBBoxRight(inst)
								shapeLeft=shapeRight-vncapTermWidth
								shapeTop=metal4shapeBottom
								shapeBottom=getBBoxTop(inst)
								when(dbGetTrueOverlaps(cvLay list(shapeLeft:shapeBottom+0.001 shapeRight:shapeTop-0.001) metal4layer)
									error("Unable to route net %s to %s\n",net~>name,inst~>name)
								)
								dbCreateRect(cvLay list(metal4layer "drawing") list(shapeLeft:shapeBottom shapeRight:shapeTop))
							)
						)
					)
					(instOrient=="MY"
						cond(
							(vncapTopTerm==instTerm~>name
								printf("vncapTopTerm\n")
								routeToVNCAPtopTerm=t
							)
							(vncapRightTerm==instTerm~>name
								printf("vncapLeftTerm\n")
								shapeLeft=getBBoxLeft(inst)
								shapeRight=shapeLeft+vncapTermWidth
								shapeTop=metal4shapeBottom
								shapeBottom=getBBoxTop(inst)
								when(dbGetTrueOverlaps(cvLay list(shapeLeft:shapeBottom+0.001 shapeRight:shapeTop-0.001) metal4layer)
									error("Unable to route net %s to %s\n",net~>name,inst~>name)
								)
								dbCreateRect(cvLay list(metal4layer "drawing") list(shapeLeft:shapeBottom shapeRight:shapeTop))
							)
							(vncapLeftTerm==instTerm~>name
								printf("vncapRightTerm\n")
								hapeRight=getBBoxRight(inst)
								shapeLeft=shapeRight-vncapTermWidth
								shapeTop=metal4shapeBottom
								shapeBottom=getBBoxTop(inst)
								when(dbGetTrueOverlaps(cvLay list(shapeLeft:shapeBottom+0.001 shapeRight:shapeTop-0.001) metal4layer)
									error("Unable to route net %s to %s\n",net~>name,inst~>name)
								)
								dbCreateRect(cvLay list(metal4layer "drawing") list(shapeLeft:shapeBottom shapeRight:shapeTop))
							)
						)
					)
				)
			)
			
			when(member(instTerm~>inst~>cellName pfetList) || member(instTerm~>inst~>cellName nfetList) || routeToVNCAPtopTerm
				shapeCenterX=(car(instTermHoriBoundaryTable[instTermBottom])+cadr(instTermHoriBoundaryTable[instTermBottom]))/2
				shapeCenterX=snap(shapeCenterX trackSpacing[metal3layer] ?direction "left")
				printf("shapeCenterX:%f\n",shapeCenterX)
				;shapeLeft=shapeCenterX-metal3minW/2
				;shapeRight=shapeCenterX+metal3minW/2
				shapeBottom=instTermHoriConnectTable[instTermBottom]
				when(!routeToVNCAPtopTerm shapeBottom=shapeBottom-stdVia2layer2Enc)
				;shapeTop=metal4shapeTop+stdVia3layer1Enc
				shapeTop=metal4shapeTop+stdVia3layer1Enc-(trackWidth[metal4layer]-via3size)/2

				;shapeCenterX=findTrack(cvLay shapeCenterX (shapeBottom-trackSpacing[metal3layer]) (shapeTop+trackSpacing[metal3layer]) "vertical" trackSpacing[metal3layer] trackWidth[metal3layer] metal3layer net "both")
				shapeCenterX=findTrack(cvLay shapeCenterX (shapeBottom-lineEndSpacing[metal3layer]+0.001) (shapeTop+lineEndSpacing[metal3layer]-0.001) "vertical" trackSpacing[metal3layer] trackWidth[metal3layer] metal3layer net "both")
				shapeLeft=shapeCenterX-metal3minW/2
				shapeRight=shapeLeft+metal3minW
				
				shapeCenterXfirst=shapeCenterX
				shapeLeftFirst=shapeLeft
				while(shapeLeft>car(instTermHoriBoundaryTable[instTermBottom])
					extraVia3=nil
					when(routeToVNCAPtopTerm extraVia3=t)
					when(rexMatchp(vncapMatchName car(instTermBottomTable[instTermBottom2])~>inst~>cellName) && shapeCenterX>=car(instTermHoriBoundaryTable[instTermBottom2]) && shapeCenterX<=cadr(instTermHoriBoundaryTable[instTermBottom2])
						extraVia3=t
						vncapInst=car(instTermBottomTable[instTermBottom2])~>inst
					)
					;when(routeToVNCAPtopTerm || 
					;	 (rexMatchp(vncapMatchName car(instTermBottomTable[instTermBottom2])~>inst~>cellName) && shapeCenterX>=car(instTermHoriBoundaryTable[instTermBottom2]) && shapeCenterX<=cadr(instTermHoriBoundaryTable[instTermBottom2]))
					;	wideMetal3=t
					;)
					;when(wideMetal3 shapeRight=shapeRight+2*trackSpacing[metal3layer])
					;dbCreateRect(cvLay list(metal3layer "drawing") list(shapeLeft:shapeBottom shapeRight:shapeTop))
					
					
					if(vncap then
						;when((shapeCenterX>=car(instTermHoriBoundaryTable[instTermBottom2]) && shapeCenterX<=(car(instTermHoriBoundaryTable[instTermBottom2])+vncapTermWidth)) ||
						;	 (shapeCenterX>=(cadr(instTermHoriBoundaryTable[instTermBottom2])-vncapTermWidth-2*via3size-via3minEdgeSpacing) && shapeCenterX<=cadr(instTermHoriBoundaryTable[instTermBottom2]))
						;	shapeCenterX=shapeCenterX-2*trackSpacing[metal3layer]
						;	shapeCenterX=findTrack(cvLay shapeCenterX (shapeBottom-trackSpacing[metal3layer]) (shapeTop+trackSpacing[metal3layer]) "vertical" trackSpacing[metal3layer] trackWidth[metal3layer] metal3layer net "left")
						;	shapeLeft=shapeCenterX-metal3minW/2
						;	shapeRight=shapeLeft+metal3minW
						;)
						dbCreateRect(cvLay list(metal3layer "drawing") list(shapeLeft:shapeBottom shapeRight:shapeTop))
						/*
						via3shapeLeft=shapeLeft+stdVia3layer1Enc
						via3shapeRight=via3shapeLeft+via3size
						via3=dbCreateRect(cvLay list(via3layer "drawing") list(via3shapeLeft:via3shapeBottom via3shapeRight:via3shapeTop))
						via3shapeLeft=via3shapeRight+via3minEdgeSpacing
						via3shapeRight=via3shapeLeft+via3size
						dbCreateRect(cvLay list(via3layer "drawing") list(via3shapeLeft:via3shapeBottom via3shapeRight:via3shapeTop))
						metal3shapeLeft=shapeLeft
						metal3shapeRight=metal3shapeLeft+2*stdVia3layer1Enc+2*via3size+via3minEdgeSpacing
						metal3shapeBottom=getBBoxBottom(via3)-stdVia3layer1Enc
						metal3shapeTop=getBBoxTop(via3)+stdVia3layer1Enc
						dbCreateRect(cvLay list(metal3layer "drawing") list(metal3shapeLeft:metal3shapeBottom metal3shapeRight:metal3shapeTop))
						*/
						via3shapeBottom=metal4shapeBottom+stdVia3layer2Enc
						via3shapeTop=via3shapeBottom+via3size
						dbCreateRect(cvLay list(via3layer "drawing") list(shapeLeft:via3shapeBottom shapeRight:via3shapeTop))
						via3shapeBottom=via3shapeTop+via3minEdgeSpacing
						via3shapeTop=via3shapeBottom+via3size
						dbCreateRect(cvLay list(via3layer "drawing") list(shapeLeft:via3shapeBottom shapeRight:via3shapeTop))
					else
						via3shapeBottom=metal4shapeBottom+metal4minW/2-via3size/2
						via3shapeTop=via3shapeBottom+via3size
						dbCreateRect(cvLay list(metal3layer "drawing") list(shapeLeft:shapeBottom shapeRight:shapeTop))
						dbCreateRect(cvLay list(via3layer "drawing") list(shapeLeft:via3shapeBottom shapeRight:via3shapeTop))
					)
					
					when(rexMatchp(sourceTermMatchName car(instTermBottomTable[instTermBottom])~>name) || rexMatchp(drainTermMatchName car(instTermBottomTable[instTermBottom])~>name)
						via2shapeBottom=instTermHoriConnectTable[instTermBottom]
						via2shapeTop=via2shapeBottom+via3size
						dbCreateRect(cvLay list(via2layer "drawing") list(shapeLeft:via2shapeBottom shapeRight:via2shapeTop))
					)
					
					shapeCenterX=shapeCenterX-meshSpacing[metal3layer]
					;shapeCenterX=findTrack(cvLay shapeCenterX (shapeBottom-trackSpacing[metal3layer]) (shapeTop+trackSpacing[metal3layer]) "vertical" trackSpacing[metal3layer] trackWidth[metal3layer] metal3layer net "both")
					shapeCenterX=findTrack(cvLay shapeCenterX (shapeBottom-lineEndSpacing[metal3layer]+0.001) (shapeTop+lineEndSpacing[metal3layer]-0.001) "vertical" trackSpacing[metal3layer] trackWidth[metal3layer] metal3layer net "both")
					shapeLeft=shapeCenterX-metal3minW/2
					shapeRight=shapeLeft+metal3minW
					;shapeLeft=shapeLeft-meshSpacing[metal3layer]
					;shapeRight=shapeLeft+metal3minW
					/*
					flag1=t
					while(flag1
						list1=dbGetTrueOverlaps(cvLay list(shapeLeft:shapeBottom-trackSpacing[metal3layer] shapeRight:shapeTop+trackSpacing[metal3layer]) metal3layer)
						flag1=nil
						foreach(shape list1
							when(shape~>net!=net flag1=t)
						)
						when(flag1
							shapeLeft=shapeLeft-trackSpacing[metal3layer]
							shapeRight=shapeLeft+metal3minW
						)
					)
					*/
				)
			)
			
			;;Create vertical metal3 trunks from metal4 trunk to terms below (towards right)
			when(member(instTerm~>inst~>cellName pfetList) || member(instTerm~>inst~>cellName nfetList) || routeToVNCAPtopTerm
				shapeCenterX=shapeCenterXfirst+meshSpacing[metal3layer]
				;shapeCenterX=findTrack(cvLay shapeCenterX (shapeBottom-trackSpacing[metal3layer]) (shapeTop+trackSpacing[metal3layer]) "vertical" trackSpacing[metal3layer] trackWidth[metal3layer] metal3layer net "both")
				shapeCenterX=findTrack(cvLay shapeCenterX (shapeBottom-lineEndSpacing[metal3layer]+0.001) (shapeTop+lineEndSpacing[metal3layer]-0.001) "vertical" trackSpacing[metal3layer] trackWidth[metal3layer] metal3layer net "both")
				shapeLeft=shapeCenterX-metal3minW/2
				shapeRight=shapeLeft+metal3minW
				;when(routeToVNCAPtopTerm shapeRight=shapeRight+2*trackSpacing[metal3layer])
				
				while(shapeRight<cadr(instTermHoriBoundaryTable[instTermBottom])
					/*					
					dbCreateRect(cvLay list(metal3layer "drawing") list(shapeLeft:shapeBottom shapeRight:shapeTop))
					
					via3shapeBottom=metal4shapeBottom+metal4minW/2-via3size/2
					via3shapeTop=via3shapeBottom+via3size
					if(routeToVNCAPtopTerm then
						via3shapeLeft=shapeLeft+stdVia3layer1Enc
						via3shapeRight=via3shapeLeft+via3size
						dbCreateRect(cvLay list(via3layer "drawing") list(via3shapeLeft:via3shapeBottom via3shapeRight:via3shapeTop))
						via3shapeRight=shapeRight-stdVia3layer1Enc
						via3shapeLeft=via3shapeRight-via3size
						dbCreateRect(cvLay list(via3layer "drawing") list(via3shapeLeft:via3shapeBottom via3shapeRight:via3shapeTop))
					else
						dbCreateRect(cvLay list(via3layer "drawing") list(shapeLeft:via3shapeBottom shapeRight:via3shapeTop))
					)
					*/
					/*
					dbCreateRect(cvLay list(metal3layer "drawing") list(shapeLeft:shapeBottom shapeRight:shapeTop))
					
					via3shapeBottom=metal4shapeBottom+metal4minW/2-via3size/2
					via3shapeTop=via3shapeBottom+via3size
					dbCreateRect(cvLay list(via3layer "drawing") list(shapeLeft:via3shapeBottom shapeRight:via3shapeTop))
					*/
					via3shapeBottom=metal4shapeBottom+metal4minW/2-via3size/2
					via3shapeTop=via3shapeBottom+via3size
					if(vncap then
						;when((shapeCenterX>=car(instTermHoriBoundaryTable[instTermBottom2]) && shapeCenterX<=(car(instTermHoriBoundaryTable[instTermBottom2])+vncapTermWidth)) ||
						;	 (shapeCenterX>=(cadr(instTermHoriBoundaryTable[instTermBottom2])-vncapTermWidth-2*via3size-via3minEdgeSpacing) && shapeCenterX<=cadr(instTermHoriBoundaryTable[instTermBottom2]))
						;	shapeCenterX=shapeCenterX-2*trackSpacing[metal3layer]
						;	shapeCenterX=findTrack(cvLay shapeCenterX (shapeBottom-trackSpacing[metal3layer]) (shapeTop+trackSpacing[metal3layer]) "vertical" trackSpacing[metal3layer] trackWidth[metal3layer] metal3layer net "left")
						;	shapeLeft=shapeCenterX-metal3minW/2
						;	shapeRight=shapeLeft+metal3minW
						;)
						dbCreateRect(cvLay list(metal3layer "drawing") list(shapeLeft:shapeBottom shapeRight:shapeTop))
						/*
						via3shapeLeft=shapeLeft+stdVia3layer1Enc
						via3shapeRight=via3shapeLeft+via3size
						via3=dbCreateRect(cvLay list(via3layer "drawing") list(via3shapeLeft:via3shapeBottom via3shapeRight:via3shapeTop))
						via3shapeLeft=via3shapeRight+via3minEdgeSpacing
						via3shapeRight=via3shapeLeft+via3size
						dbCreateRect(cvLay list(via3layer "drawing") list(via3shapeLeft:via3shapeBottom via3shapeRight:via3shapeTop))
						metal3shapeLeft=shapeLeft
						metal3shapeRight=metal3shapeLeft+2*stdVia3layer1Enc+2*via3size+via3minEdgeSpacing
						metal3shapeBottom=getBBoxBottom(via3)-stdVia3layer1Enc
						metal3shapeTop=getBBoxTop(via3)+stdVia3layer1Enc
						dbCreateRect(cvLay list(metal3layer "drawing") list(metal3shapeLeft:metal3shapeBottom metal3shapeRight:metal3shapeTop))
						*/
						via3shapeBottom=metal4shapeBottom+stdVia3layer2Enc
						via3shapeTop=via3shapeBottom+via3size
						dbCreateRect(cvLay list(via3layer "drawing") list(shapeLeft:via3shapeBottom shapeRight:via3shapeTop))
						via3shapeBottom=via3shapeTop+via3minEdgeSpacing
						via3shapeTop=via3shapeBottom+via3size
						dbCreateRect(cvLay list(via3layer "drawing") list(shapeLeft:via3shapeBottom shapeRight:via3shapeTop))
					else
						via3shapeBottom=metal4shapeBottom+metal4minW/2-via3size/2
						via3shapeTop=via3shapeBottom+via3size
						dbCreateRect(cvLay list(metal3layer "drawing") list(shapeLeft:shapeBottom shapeRight:shapeTop))
						dbCreateRect(cvLay list(via3layer "drawing") list(shapeLeft:via3shapeBottom shapeRight:via3shapeTop))
					)
					
					when(rexMatchp(sourceTermMatchName car(instTermBottomTable[instTermBottom])~>name) || rexMatchp(drainTermMatchName car(instTermBottomTable[instTermBottom])~>name)
						via2shapeBottom=instTermHoriConnectTable[instTermBottom]
						via2shapeTop=via2shapeBottom+via3size
						dbCreateRect(cvLay list(via2layer "drawing") list(shapeLeft:via2shapeBottom shapeRight:via2shapeTop))
					)
					
					shapeCenterX=shapeCenterX+meshSpacing[metal3layer]
					;shapeCenterX=findTrack(cvLay shapeCenterX (shapeBottom-trackSpacing[metal3layer]) (shapeTop+trackSpacing[metal3layer]) "vertical" trackSpacing[metal3layer] trackWidth[metal3layer] metal3layer net "both")
					shapeCenterX=findTrack(cvLay shapeCenterX (shapeBottom-lineEndSpacing[metal3layer]+0.001) (shapeTop+lineEndSpacing[metal3layer]-0.001) "vertical" trackSpacing[metal3layer] trackWidth[metal3layer] metal3layer net "both")
					shapeLeft=shapeCenterX-metal3minW/2
					shapeRight=shapeLeft+metal3minW
					;when(routeToVNCAPtopTerm shapeRight=shapeRight+2*trackSpacing[metal3layer])
				)
			)
			lxUpdateBinding(cvLay ?schCV cvSch)
			
			;;Create vertical metal3 trunks from metal4 trunk to terms above (towards left)
			routeToVNCAPbottomTerm=nil
			instTerm=car(instTermBottomTable[instTermBottom2])
			when(rexMatchp(vncapMatchName instTerm~>inst~>cellName)
				printf("vncap inst term:%s\n",instTerm~>name)
				inst=instTerm~>inst
				instOrient=inst~>orient
				cond(
					(instOrient=="R0"
						cond(
							(vncapBottomTerm==instTerm~>name
								printf("vncapBottomTerm\n")
								routeToVNCAPbottomTerm=t
							)
							(vncapLeftTerm==instTerm~>name
								printf("vncapLeftTerm\n")
								shapeLeft=getBBoxLeft(inst)
								shapeRight=shapeLeft+vncapTermWidth
								shapeTop=getBBoxBottom(inst)
								shapeBottom=metal4shapeTop
								when(dbGetTrueOverlaps(cvLay list(shapeLeft:shapeBottom+0.001 shapeRight:shapeTop-0.001) metal4layer)
									error("Unable to route net %s to %s\n",net~>name,inst~>name)
								)
								dbCreateRect(cvLay list(metal4layer "drawing") list(shapeLeft:shapeBottom shapeRight:shapeTop))
							)
							(vncapRightTerm==instTerm~>name
								printf("vncapRightTerm\n")
								shapeRight=getBBoxRight(inst)
								shapeLeft=shapeRight-vncapTermWidth
								shapeTop=getBBoxBottom(inst)
								shapeBottom=metal4shapeTop
								when(dbGetTrueOverlaps(cvLay list(shapeLeft:shapeBottom+0.001 shapeRight:shapeTop-0.001) metal4layer)
									error("Unable to route net %s to %s\n",net~>name,inst~>name)
								)
								dbCreateRect(cvLay list(metal4layer "drawing") list(shapeLeft:shapeBottom shapeRight:shapeTop))
							)
						)
					)
					(instOrient=="MY"
						cond(
							(vncapBottomTerm==instTerm~>name
								printf("vncapBottomTerm\n")
								routeToVNCAPbottomTerm=t
							)
							(vncapRightTerm==instTerm~>name
								printf("vncapLeftTerm\n")
								shapeLeft=getBBoxLeft(inst)
								shapeRight=shapeLeft+vncapTermWidth
								shapeTop=getBBoxBottom(inst)
								shapeBottom=metal4shapeTop
								when(dbGetTrueOverlaps(cvLay list(shapeLeft:shapeBottom+0.001 shapeRight:shapeTop-0.001) metal4layer)
									error("Unable to route net %s to %s\n",net~>name,inst~>name)
								)
								dbCreateRect(cvLay list(metal4layer "drawing") list(shapeLeft:shapeBottom shapeRight:shapeTop))
							)
							(vncapLeftTerm==instTerm~>name
								printf("vncapRightTerm\n")
								shapeRight=getBBoxRight(inst)
								shapeLeft=shapeRight-vncapTermWidth
								shapeTop=getBBoxBottom(inst)
								shapeBottom=metal4shapeTop
								when(dbGetTrueOverlaps(cvLay list(shapeLeft:shapeBottom+0.001 shapeRight:shapeTop-0.001) metal4layer)
									error("Unable to route net %s to %s\n",net~>name,inst~>name)
								)
								dbCreateRect(cvLay list(metal4layer "drawing") list(shapeLeft:shapeBottom shapeRight:shapeTop))
							)
						)
					)
				)
			)
			
			when(member(instTerm~>inst~>cellName pfetList) || member(instTerm~>inst~>cellName nfetList) || routeToVNCAPbottomTerm
				shapeCenterX=(car(instTermHoriBoundaryTable[instTermBottom2])+cadr(instTermHoriBoundaryTable[instTermBottom2]))/2
				shapeCenterX=snap(shapeCenterX trackSpacing[metal3layer] ?direction "left")
				printf("shapeCenterX:%f\n",shapeCenterX)
				;shapeLeft=shapeCenterX-metal3minW/2
				;shapeRight=shapeCenterX+metal3minW/2
				shapeTop=instTermHoriConnectTable[instTermBottom2]+metal2minW+stdVia2layer2Enc
				;shapeBottom=metal4shapeBottom-stdVia3layer1Enc
				;shapeBottom=metal4shapeBottom
				shapeBottom=metal4shapeBottom-(stdVia3layer1Enc-(trackWidth[metal4layer]-via3size)/2)

				printf("chk1:%f\n",shapeTop+trackSpacing[metal3layer])
				;shapeCenterX=findTrack(cvLay shapeCenterX (shapeBottom-trackSpacing[metal3layer]) (shapeTop+trackSpacing[metal3layer]) "vertical" trackSpacing[metal3layer] trackWidth[metal3layer] metal3layer net "both")
				shapeCenterX=findTrack(cvLay shapeCenterX (shapeBottom-lineEndSpacing[metal3layer]+0.001) (shapeTop+lineEndSpacing[metal3layer]-0.001) "vertical" trackSpacing[metal3layer] trackWidth[metal3layer] metal3layer net "both")
				shapeLeft=shapeCenterX-metal3minW/2
				shapeRight=shapeLeft+metal3minW
				
				shapeLeftFirst=shapeLeft
				shapeCenterXfirst=shapeCenterX
				while(shapeLeft>car(instTermHoriBoundaryTable[instTermBottom2])
					/*
					dbCreateRect(cvLay list(metal3layer "drawing") list(shapeLeft:shapeBottom shapeRight:shapeTop))
					
					via3shapeBottom=metal4shapeBottom+metal4minW/2-via3size/2
					via3shapeTop=via3shapeBottom+via3size
					dbCreateRect(cvLay list(via3layer "drawing") list(shapeLeft:via3shapeBottom shapeRight:via3shapeTop))
					*/
					if(vncap then
						;when((shapeCenterX>=car(instTermHoriBoundaryTable[instTermBottom2]) && shapeCenterX<=(car(instTermHoriBoundaryTable[instTermBottom2])+vncapTermWidth)) ||
						;	 (shapeCenterX>=(cadr(instTermHoriBoundaryTable[instTermBottom2])-vncapTermWidth-2*via3size-via3minEdgeSpacing) && shapeCenterX<=cadr(instTermHoriBoundaryTable[instTermBottom2]))
						;	shapeCenterX=shapeCenterX-2*trackSpacing[metal3layer]
						;	shapeCenterX=findTrack(cvLay shapeCenterX (shapeBottom-trackSpacing[metal3layer]) (shapeTop+trackSpacing[metal3layer]) "vertical" trackSpacing[metal3layer] trackWidth[metal3layer] metal3layer net "left")
						;	shapeLeft=shapeCenterX-metal3minW/2
						;	shapeRight=shapeLeft+metal3minW
						;)
						via3shapeBottom=metal4shapeBottom+stdVia3layer2Enc
						via3shapeTop=via3shapeBottom+via3size
						dbCreateRect(cvLay list(metal3layer "drawing") list(shapeLeft:shapeBottom shapeRight:shapeTop))
						dbCreateRect(cvLay list(via3layer "drawing") list(shapeLeft:via3shapeBottom shapeRight:via3shapeTop))
						via3shapeBottom=via3shapeTop+via3minEdgeSpacing
						via3shapeTop=via3shapeBottom+via3size
						dbCreateRect(cvLay list(via3layer "drawing") list(shapeLeft:via3shapeBottom shapeRight:via3shapeTop))
					else
						via3shapeBottom=metal4shapeBottom+metal4minW/2-via3size/2
						via3shapeTop=via3shapeBottom+via3size
						dbCreateRect(cvLay list(metal3layer "drawing") list(shapeLeft:shapeBottom shapeRight:shapeTop))
						dbCreateRect(cvLay list(via3layer "drawing") list(shapeLeft:via3shapeBottom shapeRight:via3shapeTop))
					)
					
					when(rexMatchp(sourceTermMatchName car(instTermBottomTable[instTermBottom2])~>name) || rexMatchp(drainTermMatchName car(instTermBottomTable[instTermBottom2])~>name)
						via2shapeBottom=instTermHoriConnectTable[instTermBottom2]
						via2shapeTop=via2shapeBottom+via3size
						dbCreateRect(cvLay list(via2layer "drawing") list(shapeLeft:via2shapeBottom shapeRight:via2shapeTop))
					)
					
					shapeCenterX=shapeCenterX-meshSpacing[metal3layer]
					;shapeCenterX=findTrack(cvLay shapeCenterX (shapeBottom-trackSpacing[metal3layer]) (shapeTop+trackSpacing[metal3layer]) "vertical" trackSpacing[metal3layer] trackWidth[metal3layer] metal3layer net "both")
					shapeCenterX=findTrack(cvLay shapeCenterX (shapeBottom-lineEndSpacing[metal3layer]+0.001) (shapeTop+lineEndSpacing[metal3layer]-0.001) "vertical" trackSpacing[metal3layer] trackWidth[metal3layer] metal3layer net "both")
					shapeLeft=shapeCenterX-metal3minW/2
					shapeRight=shapeLeft+metal3minW
				)
			)
			
			;;Create vertical metal3 trunks from metal4 trunk to terms above (towards right)
			when(member(instTerm~>inst~>cellName pfetList) || member(instTerm~>inst~>cellName nfetList) || routeToVNCAPbottomTerm
				shapeCenterX=shapeCenterXfirst+meshSpacing[metal3layer]
				;shapeCenterX=findTrack(cvLay shapeCenterX (shapeBottom-trackSpacing[metal3layer]) (shapeTop+trackSpacing[metal3layer]) "vertical" trackSpacing[metal3layer] trackWidth[metal3layer] metal3layer net "both")
				shapeCenterX=findTrack(cvLay shapeCenterX (shapeBottom-lineEndSpacing[metal3layer]+0.001) (shapeTop+lineEndSpacing[metal3layer]-0.001) "vertical" trackSpacing[metal3layer] trackWidth[metal3layer] metal3layer net "both")
				shapeLeft=shapeCenterX-metal3minW/2
				shapeRight=shapeLeft+metal3minW
				
				while(shapeLeft<cadr(instTermHoriBoundaryTable[instTermBottom2])
					/*
					dbCreateRect(cvLay list(metal3layer "drawing") list(shapeLeft:shapeBottom shapeRight:shapeTop))
					
					via3shapeBottom=metal4shapeBottom+metal4minW/2-via3size/2
					via3shapeTop=via3shapeBottom+via3size
					dbCreateRect(cvLay list(via3layer "drawing") list(shapeLeft:via3shapeBottom shapeRight:via3shapeTop))
					*/
					if(vncap then
						;when((shapeCenterX>=car(instTermHoriBoundaryTable[instTermBottom2]) && shapeCenterX<=(car(instTermHoriBoundaryTable[instTermBottom2])+vncapTermWidth)) ||
						;	 (shapeCenterX>=(cadr(instTermHoriBoundaryTable[instTermBottom2])-vncapTermWidth-2*via3size-via3minEdgeSpacing) && shapeCenterX<=cadr(instTermHoriBoundaryTable[instTermBottom2]))
						;	shapeCenterX=shapeCenterX-2*trackSpacing[metal3layer]
						;	shapeCenterX=findTrack(cvLay shapeCenterX (shapeBottom-trackSpacing[metal3layer]) (shapeTop+trackSpacing[metal3layer]) "vertical" trackSpacing[metal3layer] trackWidth[metal3layer] metal3layer net "left")
						;	shapeLeft=shapeCenterX-metal3minW/2
						;	shapeRight=shapeLeft+metal3minW
						;)
						via3shapeBottom=metal4shapeBottom+stdVia3layer2Enc
						via3shapeTop=via3shapeBottom+via3size
						dbCreateRect(cvLay list(metal3layer "drawing") list(shapeLeft:shapeBottom shapeRight:shapeTop))
						dbCreateRect(cvLay list(via3layer "drawing") list(shapeLeft:via3shapeBottom shapeRight:via3shapeTop))
						via3shapeBottom=via3shapeTop+via3minEdgeSpacing
						via3shapeTop=via3shapeBottom+via3size
						dbCreateRect(cvLay list(via3layer "drawing") list(shapeLeft:via3shapeBottom shapeRight:via3shapeTop))
					else
						via3shapeBottom=metal4shapeBottom+metal4minW/2-via3size/2
						via3shapeTop=via3shapeBottom+via3size
						dbCreateRect(cvLay list(metal3layer "drawing") list(shapeLeft:shapeBottom shapeRight:shapeTop))
						dbCreateRect(cvLay list(via3layer "drawing") list(shapeLeft:via3shapeBottom shapeRight:via3shapeTop))
					)
					
					when(rexMatchp(sourceTermMatchName car(instTermBottomTable[instTermBottom2])~>name) || rexMatchp(drainTermMatchName car(instTermBottomTable[instTermBottom2])~>name)
						via2shapeBottom=instTermHoriConnectTable[instTermBottom2]
						via2shapeTop=via2shapeBottom+via3size
						dbCreateRect(cvLay list(via2layer "drawing") list(shapeLeft:via2shapeBottom shapeRight:via2shapeTop))
					)
					
					shapeCenterX=shapeCenterX+meshSpacing[metal3layer]
					;shapeCenterX=findTrack(cvLay shapeCenterX (shapeBottom-trackSpacing[metal3layer]) (shapeTop+trackSpacing[metal3layer]) "vertical" trackSpacing[metal3layer] trackWidth[metal3layer] metal3layer net "both")
					shapeCenterX=findTrack(cvLay shapeCenterX (shapeBottom-lineEndSpacing[metal3layer]+0.001) (shapeTop+lineEndSpacing[metal3layer]-0.001) "vertical" trackSpacing[metal3layer] trackWidth[metal3layer] metal3layer net "both")
					shapeLeft=shapeCenterX-metal3minW/2
					shapeRight=shapeLeft+metal3minW
				)
			)
			lxUpdateBinding(cvLay ?schCV cvSch)
		);;for
		
		;when(length(instTermBottomList)==1
		;	instTerm=car(instTermBottomTable[car(instTermBottomList)])
		;	when(rexMatchp(sourceTermMatchName instTerm~>name) || rexMatchp(drainTermMatchName instTerm~>name)		
		;	)
		;)
	);;let
);;procedure internalRoute2

procedure(internalRoute3(cvLay cvSch net instRowTable)
	let((ioPinFig ioPinBBox ioPinCenterX ioPinCenterY 
		 instTerms instList
		 term fig bBox bBoxLeft bBoxLeftMost bBoxRight bBoxRightMost bBoxCenterX
		 instTermTable row
		 instTermBottomTable instTermBottom instTermBottomList instTermBottom2 instTermBottomList2
		 instTermList instTerm inst instTop instBottom
		 shapeBottom shapeTop shapeLeft shapeRight shapeCenterX
		 instTermHoriBoundaryTable instTermHoriConnectTable
		 i)
		printstruct(instRowTable)
		
		ioPinFig=car(net~>term~>pins)~>fig
		ioPinBBox=ioPinFig~>bBox
		ioPinCenterX=car(centerBox(ioPinBBox))
		ioPinCenterY=cadr(centerBox(ioPinBBox))
		;printf("io:%f %f\n",ioPinCenterX,ioPinCenterY)
		
		instTerms=net~>instTerms
		instList=instTerms~>inst
		instTermBottomTable=makeTable("instTermBottomTable")
		i=0
		foreach(term instTerms~>term
			fig=car(term~>pins)~>fig
			bBox=dbTransformBBox(fig~>bBox dbGetInstTransform(list(nth(i instList))))
			instTermBottom=int(bBoxBottom(bBox)*1000)
			when(!member(instTermBottom instTermBottomTable~>?) instTermBottomTable[instTermBottom]=list())
			instTermBottomTable[instTermBottom]=append(instTermBottomTable[instTermBottom] list(nth(i instTerms)))
			i=i+1
		)
		printstruct(instTermBottomTable)
		
		instTermTable=makeTable("instTermTable")
		foreach(instTerm instTerms
			inst=instTerm~>inst
			row=instRowTable[inst~>name]
			when(!member(row instTermTable~>?) instTermTable[row]=list())
			instTermTable[row]=append(instTermTable[row] list(instTerm))
		)
		printstruct(instTermTable)
		
		vncapTermOnNet=nil
		instTermHoriBoundaryTable=makeTable("instTermHoriBoundaryTable")
		instTermHoriBoundarySourceDrainTable=makeTable("instTermHoriBoundarySourceDrainTable")
		instTermHoriConnectTable=makeTable("instTermHoriConnectTable")
		gateTermBBoxTable=makeTable("gateTermBBoxTable")
		foreach(row instTermTable
			instTermList=instTermTable[row]
			;printf("%d:%L\n",instTermBottom,instTermList)
			;;Source/drain/gate term row
			when(rexMatchp(sourceTermMatchName car(instTermList)~>name) || rexMatchp(drainTermMatchName car(instTermList)~>name) || rexMatchp(gateTermMatchName car(instTermList)~>name)
				printf("source/drain/gate terms at row %d\n",row)
				bBoxLeftMost=1000
				bBoxRightMost=-1000
				bBoxLeftMostSD=1000
				bBoxRightMostSD=-1000
				sourceDrainTerm=nil
				foreach(instTerm instTermList
					fig=car(instTerm~>term~>pins)~>fig
					bBox=dbTransformBBox(fig~>bBox dbGetInstTransform(list(instTerm~>inst)))
					bBoxLeft=bBoxLeft(bBox)
					bBoxRight=bBoxRight(bBox)
					;printf("left:%f\n",bBoxLeft)
					when(bBoxLeft<bBoxLeftMost bBoxLeftMost=bBoxLeft)
					when(bBoxRight>bBoxRightMost bBoxRightMost=bBoxRight)
					
					isSourceDrainTerm=nil
					when(rexMatchp(sourceTermMatchName instTerm~>name) || rexMatchp(drainTermMatchName instTerm~>name)
						isSourceDrainTerm=t						
						sourceDrainTerm=instTerm
					)
					when(bBoxLeft<bBoxLeftMostSD && isSourceDrainTerm bBoxLeftMostSD=bBoxLeft)
					when(bBoxRight>bBoxRightMostSD && isSourceDrainTerm bBoxRightMostSD=bBoxRight)
				)
				printf("leftmost:%f rightmost:%f\n",bBoxLeftMost,bBoxRightMost)
				instTermHoriBoundaryTable[row]=list(bBoxLeftMost bBoxRightMost)
				
				when((bBoxRightMostSD-bBoxLeftMostSD)<via1size+2*stdVia1layer2Enc+0.001
					bBoxLeftMostSD=bBoxLeftMostSD-singleSDmetal2extension
					bBoxRightMostSD=bBoxRightMostSD+singleSDmetal2extension
				)
				;bBoxLeftMostSD=bBoxLeftMostSD-0.1
				;bBoxRightMostSD=bBoxRightMostSD+0.1
				instTermHoriBoundarySourceDrainTable[row]=list(bBoxLeftMostSD bBoxRightMostSD)
				
				;;Create metal2 trunk for source/drain terms
				when(sourceDrainTerm
					if(ioPinFig && ioPinFig~>layerName==metal2layer then
						shapeBottom=ioPinCenterY-metal2minW/2
						shapeTop=ioPinCenterY+metal2minW/2
					else
						sourceTermBBox=car(sourceDrainTerm~>term~>pins)~>fig~>bBox
						printf("sourceTermBBox:%L\n",sourceTermBBox)
						sourceTermBBoxBottom=bBoxBottom(sourceTermBBox)
						sourceTermBBoxTop=bBoxTop(sourceTermBBox)				
						shapeBottom=cadr(car(instTermList)~>inst~>xy)+sourceTermBBoxBottom+stdVia1layer1Enc
						shapeTop=shapeBottom+metal2minW
					)
				
				
					shapeLeft=bBoxLeftMostSD-stdVia1layer2Enc
					shapeRight=bBoxRightMostSD+stdVia1layer2Enc
					while(dbGetTrueOverlaps(cvLay list(shapeLeft-lineEndSpacing[metal2layer]:shapeBottom shapeRight+lineEndSpacing[metal2layer]:shapeTop) metal2layer)
						shapeBottom=shapeBottom+metal2minPitch+metal2minPitchExtra
						shapeTop=shapeBottom+metal2minW
					)
					
					printf("shapeLeft:%f shapeBottom:%f shapeRight:%f shapeTop:%f\n",shapeLeft,shapeBottom,shapeRight,shapeTop)
					dbCreateRect(cvLay list(metal2layer "drawing") list(shapeLeft:shapeBottom shapeRight:shapeTop))
					instTermHoriConnectTable[row]=shapeBottom
					
					;;Create via1's
					foreach(instTerm instTermList
						when(rexMatchp(sourceTermMatchName instTerm~>name) || rexMatchp(drainTermMatchName instTerm~>name)
							fig=car(instTerm~>term~>pins)~>fig
							bBox=dbTransformBBox(fig~>bBox dbGetInstTransform(list(instTerm~>inst)))
							shapeLeft=bBoxLeft(bBox)
							shapeRight=bBoxRight(bBox)
							dbCreateRect(cvLay list(via1layer "drawing") list(shapeLeft:shapeBottom shapeRight:shapeTop))
						)
					)
				)
			);;Source/drain term row
			
			;;Gate term
			foreach(instTerm setof(x instTermList rexMatchp(gateTermMatchName x~>name))
				fig=car(instTerm~>term~>pins)~>fig
				bBox=dbTransformBBox(fig~>bBox dbGetInstTransform(list(instTerm~>inst)))	
							
				cutRows=int(((bBoxRight(bBox)-bBoxLeft(bBox))-2*stdVia1layer2Enc)/(stdVia1minCutspacing+via1size))+1
				dbCreateVia(cvLay stdVia1def centerBox(bBox) "R90" list(list("cutRows" cutRows) list("cutSpacing" list(stdVia1minCutspacing stdVia1minCutspacing))))
				dbCreateRect(cvLay list(metal2layer "drawing") list(bBoxLeft(bBox)-stdVia2layer1Enc:bBoxBottom(bBox) bBoxRight(bBox)+stdVia2layer1Enc:bBoxTop(bBox)))
				
				gateTermBBoxTable[instTerm]=bBox
			)
			
			;;VNCAP term row
			when(rexMatchp(vncapMatchName car(instTermList)~>inst~>cellName)
				printf("VNCAP terms at row %d\n",row)
				inst=car(instTermList)~>inst
				vncapTermOnNet=t
				vncapInst=inst
				when(lindex(metalLayerList metal3layer)<lindex(metalLayerList get(inst vncapBotLevParamRead)) || 
					 lindex(metalLayerList metal3layer)>lindex(metalLayerList get(inst vncapTopLevParamRead))
					error("Internal routing is only supported for VNCAPs that include metal3\n")
				)
				
				instTermHoriBoundaryTable[row]=list()
				bBoxLeftMost=1000
				bBoxRightMost=-1000
				foreach(instTerm instTermList
					fig=car(instTerm~>term~>pins)~>fig
					;fig~>lpp=list("M3" "drawing")
					bBox=dbTransformBBox(fig~>bBox dbGetInstTransform(list(instTerm~>inst)))
					bBoxLeft=bBoxLeft(bBox)
					bBoxRight=bBoxRight(bBox)
					bBoxCenterX=car(centerBox(bBox))
					printf("pin center x:%f\n",bBoxCenterX)
					when(bBoxLeft<bBoxLeftMost bBoxLeftMost=bBoxLeft)
					when(bBoxRight>bBoxRightMost bBoxRightMost=bBoxRight)
				)
				instTermHoriBoundaryTable[row]=append(instTermHoriBoundaryTable[row] list(bBoxLeftMost bBoxRightMost))
				instTermHoriConnectTable[row]=bBoxBottom(bBox)
			);;VNCAP term row
		);;For each term row
		printstruct(instTermHoriBoundaryTable)
		
		pinFigList=setof(x cvLay~>shapes x~>purpose=="pin" && x~>net==net)
		printf("pinFigList:%L\n",pinFigList~>net~>name)
		
		metal4trunkTable=makeTable("metal4trunkTable")
		metal4trunkList=list()
		rowList=sort(instTermHoriBoundaryTable~>? 'lessp)
		;for(row car(rowList) car(last(rowList))-1
		if(length(rowList)==1 then
			max_i=0
			singleRow=t
			printf("singleRow\n")
		else
			max_i=length(rowList)-2
			singleRow=nil
		)
		for(i 0 max_i
			row=nth(i rowList)
			printf("row:%d\n",row)
			printf("instTermHoriBoundary:%L\n",instTermHoriBoundaryTable[row])
			instTermList=instTermTable[row]
			instTop=bBoxTop(car(instTermList)~>inst~>bBox)
			printf("instTop:%f\n",instTop)
			
			nextRow=row
			instTermList2=instTermList
			when(!singleRow
				nextRow=nth((i+1) rowList)
				instTermList2=instTermTable[nextRow]
				;printf("%L\n",instTermList2)
				instBottom=bBoxBottom(car(instTermList2)~>inst~>bBox)
				printf("instBottom:%f\n",instBottom)
			)
			
			;;Create horizontal metal4 trunk
			shapeLeft=car(instTermHoriBoundaryTable[row])
			when(listp(instTermHoriBoundarySourceDrainTable[row])
				when(shapeLeft>car(instTermHoriBoundarySourceDrainTable[row])
					shapeLeft=car(instTermHoriBoundarySourceDrainTable[row])
				)
			)
			when(shapeLeft>car(instTermHoriBoundaryTable[nextRow])
				shapeLeft=car(instTermHoriBoundaryTable[nextRow])
			)
			when(listp(instTermHoriBoundarySourceDrainTable[nextRow])
				when(shapeLeft>car(instTermHoriBoundarySourceDrainTable[nextRow])
					shapeLeft=car(instTermHoriBoundarySourceDrainTable[nextRow])
				)
			)
			shapeLeft=shapeLeft-stdVia3layer2Enc
			
			shapeRight=cadr(instTermHoriBoundaryTable[row])
			when(listp(instTermHoriBoundarySourceDrainTable[row])
				when(shapeRight<cadr(instTermHoriBoundarySourceDrainTable[row])
					shapeRight=cadr(instTermHoriBoundarySourceDrainTable[row])
				)
			)
			when(shapeRight<cadr(instTermHoriBoundaryTable[nextRow])
				shapeRight=cadr(instTermHoriBoundaryTable[nextRow])
			)
			when(listp(instTermHoriBoundarySourceDrainTable[nextRow])
				when(shapeRight<cadr(instTermHoriBoundarySourceDrainTable[nextRow])
					shapeRight=cadr(instTermHoriBoundarySourceDrainTable[nextRow])
				)
			)
			shapeRight=shapeRight+stdVia3layer2Enc
			printf("shapeLeft:%f shapeRight:%f\n",shapeLeft,shapeRight)
			
			vncap=nil
			when(rexMatchp(vncapMatchName car(instTermTable[row])~>inst~>cellName) || rexMatchp(vncapMatchName car(instTermTable[nextRow])~>inst~>cellName)
				vncap=t
			)
			
			singleRowPos=nil
			if(!singleRow then
				if(ioPinFig && ioPinCenterY>bBoxBottom(car(instTermList)~>inst~>bBox) && ioPinCenterY<bBoxTop(car(instTermList2)~>inst~>bBox) then
					printf("ioPinCenterY:%f\n",ioPinCenterY)
					metal4shapeCenterY=ioPinCenterY
					when(ioPinCenterX<shapeLeft shapeLeft=bBoxLeft(ioPinBBox))
					when(ioPinCenterX>shapeRight shapeRight=bBoxRight(ioPinBBox))
				else
					flag1=t
					foreach(pinFig pinFigList
						pinFigCenterY=cadr(centerBox(pinFig~>bBox))
						pinFigCenterX=car(centerBox(pinFig~>bBox))
						printf("pinFigCenterY:%f\n",pinFigCenterY)
						when(pinFigCenterY>getBBoxBottom(car(instTermList)~>inst) && pinFigCenterY<getBBoxTop(car(instTermList2)~>inst)
							printf("found pinFig\n")
							flag1=nil
							metal4shapeCenterY=pinFigCenterY
							when(pinFigCenterX<shapeLeft shapeLeft=getBBoxLeft(pinFig))
							when(pinFigCenterX>shapeRight shapeRight=getBBoxRight(pinFig))
						)
					)
					when(flag1
						metal4shapeCenterY=(instTop+instBottom)/2
						metal4shapeCenterY=snap(metal4shapeCenterY trackSpacing[metal4layer])
					)
				)
			else
				if(ioPinFig then
					printf("ioPinCenterY:%f\n",ioPinCenterY)
					metal4shapeCenterY=ioPinCenterY
					when(ioPinCenterX<shapeLeft shapeLeft=bBoxLeft(ioPinBBox))
					when(ioPinCenterX>shapeRight shapeRight=bBoxRight(ioPinBBox))
				else
					if(pinFig then
						pinFig=car(pinFigList)
						pinFigCenterY=cadr(centerBox(pinFig~>bBox))
						pinFigCenterX=car(centerBox(pinFig~>bBox))
						printf("pinFigCenterY:%f\n",pinFigCenterY)
						metal4shapeCenterY=pinFigCenterY
						when(pinFigCenterX<shapeLeft shapeLeft=getBBoxLeft(pinFig))
						when(pinFigCenterX>shapeRight shapeRight=getBBoxRight(pinFig))
					else
						error("No IO pin or pin fig found\n")
					)
				)
				if(metal4shapeCenterY>instTop then
					singleRowPos="bottom"
				else
					singleRowPos="top"
				)
			)
			printf("	metal4shapeCenterY:%f\n",metal4shapeCenterY)

			metal4width=trackWidth[metal4layer]
			when(vncap metal4width=metal4wideW)
			;metal4shapeCenterY=findTrack(cvLay metal4shapeCenterY (shapeLeft-edgeSpacing[metal4layer]) (shapeRight+edgeSpacing[metal4layer]) "horizontal" trackSpacing[metal4layer] (metal4width+2*(trackSpacing[metal4layer]-trackWidth[metal4layer])) metal4layer net "both")
			metal4shapeCenterY=findTrack(cvLay metal4shapeCenterY (shapeLeft-edgeSpacing[metal4layer]) (shapeRight+edgeSpacing[metal4layer]) "horizontal" trackSpacing[metal4layer] (metal4width+edgeSpacing[metal4layer]) metal4layer net "both")
			printf("	metal4shapeCenterY:%f\n",metal4shapeCenterY)
			metal4shapeBottom=metal4shapeCenterY-metal4width/2
			metal4shapeTop=metal4shapeBottom+metal4width
			metal4trunk=dbCreateRect(cvLay list(metal4layer "drawing") list(shapeLeft:metal4shapeBottom shapeRight:metal4shapeTop))
			metal4trunkList=append(metal4trunkList list(metal4trunk))
			when(!singleRow
				sprintf(str1 "%d_%d",row,nextRow)
				printf("metal4trunkTable[%s]:%s\n",str1,metal4trunk)
				metal4trunkTable[str1]=metal4trunk
			)
			metal4shapeLeft=shapeLeft
			metal4shapeRight=shapeRight
			
			when(!singleRow || singleRowPos=="bottom"
				;;Create vertical metal3 trunks from metal4 trunk to terms below (towards left)
				routeToVNCAPtopTerm=nil
				instTerm=car(instTermTable[row])
				when(rexMatchp(vncapMatchName instTerm~>inst~>cellName)
					foreach(instTerm instTermTable[row]
						printf("vncap inst term:%s\n",instTerm~>name)
						inst=instTerm~>inst
						instOrient=inst~>orient
						cond(
							(instOrient=="R0"
								cond(
									(vncapTopTerm==instTerm~>name
										printf("vncapTopTerm\n")
										routeToVNCAPtopTerm=t
									)
									(vncapLeftTerm==instTerm~>name
										printf("vncapLeftTerm\n")
										shapeLeft=getBBoxLeft(inst)
										shapeRight=shapeLeft+vncapTermWidth
										shapeTop=metal4shapeBottom
										shapeBottom=getBBoxTop(inst)
										when(dbGetTrueOverlaps(cvLay list(shapeLeft:shapeBottom+0.001 shapeRight:shapeTop-0.001) metal4layer)
											error("Unable to route net %s to %s\n",net~>name,inst~>name)
										)
										dbCreateRect(cvLay list(metal4layer "drawing") list(shapeLeft:shapeBottom shapeRight:shapeTop))
									)
									/*
									(vncapRightTerm==instTerm~>name
										printf("vncapRightTerm\n")
										shapeRight=getBBoxRight(inst)
										shapeLeft=shapeRight-vncapTermWidth
										shapeTop=metal4shapeBottom
										shapeBottom=getBBoxTop(inst)
										when(dbGetTrueOverlaps(cvLay list(shapeLeft:shapeBottom+0.001 shapeRight:shapeTop-0.001) metal4layer)
											error("Unable to route net %s to %s\n",net~>name,inst~>name)
										)
										dbCreateRect(cvLay list(metal4layer "drawing") list(shapeLeft:shapeBottom shapeRight:shapeTop))
									)
									*/
								)
							)
							(instOrient=="MX"
								cond(
									(vncapBottomTerm==instTerm~>name
										printf("vncapBottomTerm\n")
										routeToVNCAPtopTerm=t
									)
									/*
									(vncapLeftTerm==instTerm~>name
										printf("vncapLeftTerm\n")
										shapeLeft=getBBoxLeft(inst)
										shapeRight=shapeLeft+vncapTermWidth
										shapeTop=metal4shapeBottom
										shapeBottom=getBBoxTop(inst)
										when(dbGetTrueOverlaps(cvLay list(shapeLeft:shapeBottom+0.001 shapeRight:shapeTop-0.001) metal4layer)
											error("Unable to route net %s to %s\n",net~>name,inst~>name)
										)
										dbCreateRect(cvLay list(metal4layer "drawing") list(shapeLeft:shapeBottom shapeRight:shapeTop))
									)
									*/
									(vncapRightTerm==instTerm~>name
										printf("vncapRightTerm\n")
										shapeRight=getBBoxRight(inst)
										shapeLeft=shapeRight-vncapTermWidth
										shapeTop=metal4shapeBottom
										shapeBottom=getBBoxTop(inst)
										when(dbGetTrueOverlaps(cvLay list(shapeLeft:shapeBottom+0.001 shapeRight:shapeTop-0.001) metal4layer)
											error("Unable to route net %s to %s\n",net~>name,inst~>name)
										)
										dbCreateRect(cvLay list(metal4layer "drawing") list(shapeLeft:shapeBottom shapeRight:shapeTop))
									)
								)
							)
							(instOrient=="MY"
								cond(
									(vncapTopTerm==instTerm~>name
										printf("vncapTopTerm\n")
										routeToVNCAPtopTerm=t
									)
									/*
									(vncapRightTerm==instTerm~>name
										printf("vncapLeftTerm\n")
										shapeLeft=getBBoxLeft(inst)
										shapeRight=shapeLeft+vncapTermWidth
										shapeTop=metal4shapeBottom
										shapeBottom=getBBoxTop(inst)
										when(dbGetTrueOverlaps(cvLay list(shapeLeft:shapeBottom+0.001 shapeRight:shapeTop-0.001) metal4layer)
											error("Unable to route net %s to %s\n",net~>name,inst~>name)
										)
										dbCreateRect(cvLay list(metal4layer "drawing") list(shapeLeft:shapeBottom shapeRight:shapeTop))
									)
									*/
									(vncapLeftTerm==instTerm~>name
										printf("vncapRightTerm\n")
										shapeRight=getBBoxRight(inst)
										shapeLeft=shapeRight-vncapTermWidth
										shapeTop=metal4shapeBottom
										shapeBottom=getBBoxTop(inst)
										when(dbGetTrueOverlaps(cvLay list(shapeLeft:shapeBottom+0.001 shapeRight:shapeTop-0.001) metal4layer)
											error("Unable to route net %s to %s\n",net~>name,inst~>name)
										)
										dbCreateRect(cvLay list(metal4layer "drawing") list(shapeLeft:shapeBottom shapeRight:shapeTop))
									)
								)
							)
						)
					)
				)
				
				when(member(row instTermHoriConnectTable~>?) && (member(instTerm~>inst~>cellName pfetList) || member(instTerm~>inst~>cellName nfetList) || routeToVNCAPtopTerm)
					;NOTE: Only for source/drain and VNCAP terms - new code needed for gate terms
					if(routeToVNCAPtopTerm then
						instTermHoriBoundaryLeft=car(instTermHoriBoundaryTable[row])
						instTermHoriBoundaryRight=cadr(instTermHoriBoundaryTable[row])
					else
						instTermHoriBoundaryLeft=car(instTermHoriBoundarySourceDrainTable[row])
						instTermHoriBoundaryRight=cadr(instTermHoriBoundarySourceDrainTable[row])
					)
					shapeCenterX=(instTermHoriBoundaryLeft+instTermHoriBoundaryRight)/2
					shapeCenterX=snap(shapeCenterX trackSpacing[metal3layer] ?direction "left")
					shapeBottom=instTermHoriConnectTable[row]
					when(!routeToVNCAPtopTerm shapeBottom=shapeBottom-stdVia2layer2Enc)
					shapeTop=metal4shapeTop+stdVia3layer1Enc-(trackWidth[metal4layer]-via3size)/2
	
					shapeCenterX=findTrack(cvLay shapeCenterX (shapeBottom-lineEndSpacing[metal3layer]+0.001) (shapeTop+lineEndSpacing[metal3layer]-0.001) "vertical" trackSpacing[metal3layer] trackWidth[metal3layer] metal3layer net "both")
					printf("shapeCenterX:%f instTermHoriBoundaryLeft:%f\n",shapeCenterX,instTermHoriBoundaryLeft)
					shapeLeft=shapeCenterX-metal3minW/2
					shapeRight=shapeLeft+metal3minW
					
					shapeCenterXfirst=shapeCenterX
					shapeLeftFirst=shapeLeft
					while(shapeLeft>instTermHoriBoundaryLeft
						flag1=t
						when(vncap
							flag1=nil
							foreach(instTerm instTermList
								when(shapeLeft>getBBoxLeft(instTerm~>inst) && shapeRight<getBBoxRight(instTerm~>inst) flag1=t)
							)
						)
						
						when(flag1
							dbCreateRect(cvLay list(metal3layer "drawing") list(shapeLeft:shapeBottom shapeRight:shapeTop))
							if(vncap then
								via3shapeBottom=metal4shapeBottom+stdVia3layer2Enc
								via3shapeTop=via3shapeBottom+via3size
								dbCreateRect(cvLay list(via3layer "drawing") list(shapeLeft:via3shapeBottom shapeRight:via3shapeTop))
								via3shapeBottom=via3shapeTop+via3minEdgeSpacing
								via3shapeTop=via3shapeBottom+via3size
								dbCreateRect(cvLay list(via3layer "drawing") list(shapeLeft:via3shapeBottom shapeRight:via3shapeTop))
							else
								via3shapeBottom=metal4shapeBottom+metal4minW/2-via3size/2
								via3shapeTop=via3shapeBottom+via3size
								dbCreateRect(cvLay list(via3layer "drawing") list(shapeLeft:via3shapeBottom shapeRight:via3shapeTop))
							)
						)
						
						when(rexMatchp(sourceTermMatchName car(instTermTable[row])~>name) || rexMatchp(drainTermMatchName car(instTermTable[row])~>name) || rexMatchp(gateTermMatchName car(instTermTable[row])~>name)
							via2shapeBottom=instTermHoriConnectTable[row]
							via2shapeTop=via2shapeBottom+via3size
							dbCreateRect(cvLay list(via2layer "drawing") list(shapeLeft:via2shapeBottom shapeRight:via2shapeTop))
						)
						
						shapeCenterX=shapeCenterX-meshSpacing[metal3layer]
						shapeCenterX=findTrack(cvLay shapeCenterX (shapeBottom-lineEndSpacing[metal3layer]+0.001) (shapeTop+lineEndSpacing[metal3layer]-0.001) "vertical" trackSpacing[metal3layer] trackWidth[metal3layer] metal3layer net "both")
						shapeLeft=shapeCenterX-metal3minW/2
						shapeRight=shapeLeft+metal3minW
					)
					
					shapeLeft=shapeLeft+meshSpacing[metal3layer]
					when(metal4shapeLeft>shapeLeft
						leStretchFig(metal4trunk -(metal4shapeLeft-shapeLeft+stdVia3layer2Enc):0 list(t t nil nil))
					)
				)
			
			
				;;Create vertical metal3 trunks from metal4 trunk to terms below (towards right)
				when(member(row instTermHoriConnectTable~>?) && (member(instTerm~>inst~>cellName pfetList) || member(instTerm~>inst~>cellName nfetList) || routeToVNCAPtopTerm)
					;NOTE: Only for source/drain and VNCAP terms - new code needed for gate terms
					shapeCenterX=shapeCenterXfirst+meshSpacing[metal3layer]
					shapeCenterX=findTrack(cvLay shapeCenterX (shapeBottom-lineEndSpacing[metal3layer]+0.001) (shapeTop+lineEndSpacing[metal3layer]-0.001) "vertical" trackSpacing[metal3layer] trackWidth[metal3layer] metal3layer net "both")
					shapeLeft=shapeCenterX-metal3minW/2
					shapeRight=shapeLeft+metal3minW
					
					while(shapeRight<instTermHoriBoundaryRight
						flag1=t
						when(vncap
							flag1=nil
							foreach(instTerm instTermList
								when(shapeLeft>getBBoxLeft(instTerm~>inst) && shapeRight<getBBoxRight(instTerm~>inst) flag1=t)
							)
						)
						
						when(flag1
							dbCreateRect(cvLay list(metal3layer "drawing") list(shapeLeft:shapeBottom shapeRight:shapeTop))
							if(vncap then
								via3shapeBottom=metal4shapeBottom+stdVia3layer2Enc
								via3shapeTop=via3shapeBottom+via3size
								dbCreateRect(cvLay list(via3layer "drawing") list(shapeLeft:via3shapeBottom shapeRight:via3shapeTop))
								via3shapeBottom=via3shapeTop+via3minEdgeSpacing
								via3shapeTop=via3shapeBottom+via3size
								dbCreateRect(cvLay list(via3layer "drawing") list(shapeLeft:via3shapeBottom shapeRight:via3shapeTop))
							else
								via3shapeBottom=metal4shapeBottom+metal4minW/2-via3size/2
								via3shapeTop=via3shapeBottom+via3size
								dbCreateRect(cvLay list(via3layer "drawing") list(shapeLeft:via3shapeBottom shapeRight:via3shapeTop))
							)
						)
						
						when(rexMatchp(sourceTermMatchName car(instTermTable[row])~>name) || rexMatchp(drainTermMatchName car(instTermTable[row])~>name) || rexMatchp(gateTermMatchName car(instTermTable[row])~>name)
							via2shapeBottom=instTermHoriConnectTable[row]
							via2shapeTop=via2shapeBottom+via3size
							dbCreateRect(cvLay list(via2layer "drawing") list(shapeLeft:via2shapeBottom shapeRight:via2shapeTop))
						)
						
						shapeCenterX=shapeCenterX+meshSpacing[metal3layer]
						shapeCenterX=findTrack(cvLay shapeCenterX (shapeBottom-lineEndSpacing[metal3layer]+0.001) (shapeTop+lineEndSpacing[metal3layer]-0.001) "vertical" trackSpacing[metal3layer] trackWidth[metal3layer] metal3layer net "both")
						shapeLeft=shapeCenterX-metal3minW/2
						shapeRight=shapeLeft+metal3minW
					)
					
					shapeRight=shapeRight-meshSpacing[metal3layer]
					when(metal4shapeRight<shapeRight
						leStretchFig(metal4trunk (shapeRight-metal4shapeRight+stdVia3layer2Enc):0 list(nil nil t t))
					)
				)
				lceExtract(cvLay1)
			)
			
			when(!singleRow || singleRowPos=="top"
				;;Create vertical metal3 trunks from metal4 trunk to terms above (towards left)
				routeToVNCAPbottomTerm=nil
				instTerm=car(instTermTable[nextRow])
				when(rexMatchp(vncapMatchName instTerm~>inst~>cellName)
					printf("vncap inst term:%s\n",instTerm~>name)
					inst=instTerm~>inst
					instOrient=inst~>orient
					cond(
						(instOrient=="R0"
							cond(
								(vncapBottomTerm==instTerm~>name
									printf("vncapBottomTerm\n")
									routeToVNCAPbottomTerm=t
								)
								/*
								(vncapLeftTerm==instTerm~>name
									printf("vncapLeftTerm\n")
									shapeLeft=getBBoxLeft(inst)
									shapeRight=shapeLeft+vncapTermWidth
									shapeTop=getBBoxBottom(inst)
									shapeBottom=metal4shapeTop
									when(dbGetTrueOverlaps(cvLay list(shapeLeft:shapeBottom+0.001 shapeRight:shapeTop-0.001) metal4layer)
										error("Unable to route net %s to %s\n",net~>name,inst~>name)
									)
									dbCreateRect(cvLay list(metal4layer "drawing") list(shapeLeft:shapeBottom shapeRight:shapeTop))
								)
								*/
								(vncapRightTerm==instTerm~>name
									printf("vncapRightTerm\n")
									shapeRight=getBBoxRight(inst)
									shapeLeft=shapeRight-vncapTermWidth
									shapeTop=getBBoxBottom(inst)
									shapeBottom=metal4shapeTop
									when(dbGetTrueOverlaps(cvLay list(shapeLeft:shapeBottom+0.001 shapeRight:shapeTop-0.001) metal4layer)
										error("Unable to route net %s to %s\n",net~>name,inst~>name)
									)
									dbCreateRect(cvLay list(metal4layer "drawing") list(shapeLeft:shapeBottom shapeRight:shapeTop))
								)
							)
						)
						(instOrient=="MX"
							cond(
								(vncapTopTerm==instTerm~>name
									printf("vncapBottomTerm\n")
									routeToVNCAPbottomTerm=t
								)
								(vncapLeftTerm==instTerm~>name
									printf("vncapLeftTerm\n")
									shapeLeft=getBBoxLeft(inst)
									shapeRight=shapeLeft+vncapTermWidth
									shapeTop=getBBoxBottom(inst)
									shapeBottom=metal4shapeTop
									when(dbGetTrueOverlaps(cvLay list(shapeLeft:shapeBottom+0.001 shapeRight:shapeTop-0.001) metal4layer)
										error("Unable to route net %s to %s\n",net~>name,inst~>name)
									)
									dbCreateRect(cvLay list(metal4layer "drawing") list(shapeLeft:shapeBottom shapeRight:shapeTop))
								)
								/*
								(vncapRightTerm==instTerm~>name
									printf("vncapRightTerm\n")
									shapeRight=getBBoxRight(inst)
									shapeLeft=shapeRight-vncapTermWidth
									shapeTop=getBBoxBottom(inst)
									shapeBottom=metal4shapeTop
									when(dbGetTrueOverlaps(cvLay list(shapeLeft:shapeBottom+0.001 shapeRight:shapeTop-0.001) metal4layer)
										error("Unable to route net %s to %s\n",net~>name,inst~>name)
									)
									dbCreateRect(cvLay list(metal4layer "drawing") list(shapeLeft:shapeBottom shapeRight:shapeTop))
								)
								*/
							)
						)
						(instOrient=="MY"
							cond(
								(vncapBottomTerm==instTerm~>name
									printf("vncapBottomTerm\n")
									routeToVNCAPbottomTerm=t
								)
								(vncapRightTerm==instTerm~>name
									printf("vncapLeftTerm\n")
									shapeLeft=getBBoxLeft(inst)
									shapeRight=shapeLeft+vncapTermWidth
									shapeTop=getBBoxBottom(inst)
									shapeBottom=metal4shapeTop
									when(dbGetTrueOverlaps(cvLay list(shapeLeft:shapeBottom+0.001 shapeRight:shapeTop-0.001) metal4layer)
										error("Unable to route net %s to %s\n",net~>name,inst~>name)
									)
									dbCreateRect(cvLay list(metal4layer "drawing") list(shapeLeft:shapeBottom shapeRight:shapeTop))
								)
								/*
								(vncapLeftTerm==instTerm~>name
									printf("vncapRightTerm\n")
									shapeRight=getBBoxRight(inst)
									shapeLeft=shapeRight-vncapTermWidth
									shapeTop=getBBoxBottom(inst)
									shapeBottom=metal4shapeTop
									when(dbGetTrueOverlaps(cvLay list(shapeLeft:shapeBottom+0.001 shapeRight:shapeTop-0.001) metal4layer)
										error("Unable to route net %s to %s\n",net~>name,inst~>name)
									)
									dbCreateRect(cvLay list(metal4layer "drawing") list(shapeLeft:shapeBottom shapeRight:shapeTop))
								)
								*/
							)
						)
					)
				)
				
				when(member(nextRow instTermHoriConnectTable~>?) && (member(instTerm~>inst~>cellName pfetList) || member(instTerm~>inst~>cellName nfetList) || routeToVNCAPbottomTerm)
					;NOTE: Only for source/drain and VNCAP terms - new code needed for gate terms
					if(routeToVNCAPbottomTerm then
						instTermHoriBoundaryLeft=car(instTermHoriBoundaryTable[nextRow])
						instTermHoriBoundaryRight=cadr(instTermHoriBoundaryTable[nextRow])
					else
						instTermHoriBoundaryLeft=car(instTermHoriBoundarySourceDrainTable[nextRow])
						instTermHoriBoundaryRight=cadr(instTermHoriBoundarySourceDrainTable[nextRow])
					)
					shapeCenterX=(instTermHoriBoundaryLeft+instTermHoriBoundaryRight)/2
					;shapeCenterX=(car(instTermHoriBoundarySourceDrainTable[nextRow])+cadr(instTermHoriBoundarySourceDrainTable[nextRow]))/2
					shapeCenterX=snap(shapeCenterX trackSpacing[metal3layer] ?direction "left")
					printf("chk1:shapeCenterX:%f\n",shapeCenterX)
					shapeTop=instTermHoriConnectTable[nextRow]+metal2minW+stdVia2layer2Enc
					shapeBottom=metal4shapeBottom-(stdVia3layer1Enc-(trackWidth[metal4layer]-via3size)/2)
	
					shapeCenterX=findTrack(cvLay shapeCenterX (shapeBottom-lineEndSpacing[metal3layer]+0.001) (shapeTop+lineEndSpacing[metal3layer]-0.001) "vertical" trackSpacing[metal3layer] trackWidth[metal3layer] metal3layer net "both")
					printf("chk2:shapeCenterX:%f\n",shapeCenterX)					
					shapeLeft=shapeCenterX-metal3minW/2
					shapeRight=shapeLeft+metal3minW
					
					shapeLeftFirst=shapeLeft
					shapeCenterXfirst=shapeCenterX
					while(shapeLeft>instTermHoriBoundaryLeft
						flag1=t
						when(vncap
							flag1=nil
							foreach(instTerm instTermList2
								when(shapeLeft>getBBoxLeft(instTerm~>inst) && shapeRight<getBBoxRight(instTerm~>inst) flag1=t)
							)
						)
						
						when(flag1
							dbCreateRect(cvLay list(metal3layer "drawing") list(shapeLeft:shapeBottom shapeRight:shapeTop))
							if(vncap then
								via3shapeBottom=metal4shapeBottom+stdVia3layer2Enc
								via3shapeTop=via3shapeBottom+via3size
								dbCreateRect(cvLay list(via3layer "drawing") list(shapeLeft:via3shapeBottom shapeRight:via3shapeTop))
								via3shapeBottom=via3shapeTop+via3minEdgeSpacing
								via3shapeTop=via3shapeBottom+via3size
								dbCreateRect(cvLay list(via3layer "drawing") list(shapeLeft:via3shapeBottom shapeRight:via3shapeTop))
							else
								via3shapeBottom=metal4shapeBottom+metal4minW/2-via3size/2
								via3shapeTop=via3shapeBottom+via3size
								dbCreateRect(cvLay list(via3layer "drawing") list(shapeLeft:via3shapeBottom shapeRight:via3shapeTop))
							)
						)
						
						when(rexMatchp(sourceTermMatchName car(instTermTable[nextRow])~>name) || rexMatchp(drainTermMatchName car(instTermTable[nextRow])~>name) || rexMatchp(gateTermMatchName car(instTermTable[nextRow])~>name)
							via2shapeBottom=instTermHoriConnectTable[nextRow]
							via2shapeTop=via2shapeBottom+via3size
							dbCreateRect(cvLay list(via2layer "drawing") list(shapeLeft:via2shapeBottom shapeRight:via2shapeTop))
						)
						
						shapeCenterX=shapeCenterX-meshSpacing[metal3layer]
						shapeCenterX=findTrack(cvLay shapeCenterX (shapeBottom-lineEndSpacing[metal3layer]+0.001) (shapeTop+lineEndSpacing[metal3layer]-0.001) "vertical" trackSpacing[metal3layer] trackWidth[metal3layer] metal3layer net "both")
						shapeLeft=shapeCenterX-metal3minW/2
						shapeRight=shapeLeft+metal3minW
					)
					
					shapeLeft=shapeLeft+meshSpacing[metal3layer]
					when(metal4shapeLeft>shapeLeft
						leStretchFig(metal4trunk -(metal4shapeLeft-shapeLeft+stdVia3layer2Enc):0 list(t t nil nil))
					)
				)
				
				;;Create vertical metal3 trunks from metal4 trunk to terms above (towards right)
				when(member(nextRow instTermHoriConnectTable~>?) && (member(instTerm~>inst~>cellName pfetList) || member(instTerm~>inst~>cellName nfetList) || routeToVNCAPbottomTerm)
					;NOTE: Only for source/drain and VNCAP terms - new code needed for gate terms
					shapeCenterX=shapeCenterXfirst+meshSpacing[metal3layer]
					shapeCenterX=findTrack(cvLay shapeCenterX (shapeBottom-lineEndSpacing[metal3layer]+0.001) (shapeTop+lineEndSpacing[metal3layer]-0.001) "vertical" trackSpacing[metal3layer] trackWidth[metal3layer] metal3layer net "both")
					shapeLeft=shapeCenterX-metal3minW/2
					shapeRight=shapeLeft+metal3minW
					
					while(shapeRight<instTermHoriBoundaryRight
						flag1=t
						when(vncap
							flag1=nil
							foreach(instTerm instTermList2
								when(shapeLeft>getBBoxLeft(instTerm~>inst) && shapeRight<getBBoxRight(instTerm~>inst) flag1=t)
							)
						)
						
						when(flag1
							dbCreateRect(cvLay list(metal3layer "drawing") list(shapeLeft:shapeBottom shapeRight:shapeTop))
							if(vncap then
								via3shapeBottom=metal4shapeBottom+stdVia3layer2Enc
								via3shapeTop=via3shapeBottom+via3size
								dbCreateRect(cvLay list(via3layer "drawing") list(shapeLeft:via3shapeBottom shapeRight:via3shapeTop))
								via3shapeBottom=via3shapeTop+via3minEdgeSpacing
								via3shapeTop=via3shapeBottom+via3size
								dbCreateRect(cvLay list(via3layer "drawing") list(shapeLeft:via3shapeBottom shapeRight:via3shapeTop))
							else
								via3shapeBottom=metal4shapeBottom+metal4minW/2-via3size/2
								via3shapeTop=via3shapeBottom+via3size
								dbCreateRect(cvLay list(via3layer "drawing") list(shapeLeft:via3shapeBottom shapeRight:via3shapeTop))
							)
						)
						
						when(rexMatchp(sourceTermMatchName car(instTermTable[nextRow])~>name) || rexMatchp(drainTermMatchName car(instTermTable[nextRow])~>name) || rexMatchp(gateTermMatchName car(instTermTable[nextRow])~>name)
							via2shapeBottom=instTermHoriConnectTable[nextRow]
							via2shapeTop=via2shapeBottom+via3size
							dbCreateRect(cvLay list(via2layer "drawing") list(shapeLeft:via2shapeBottom shapeRight:via2shapeTop))
						)
						
						shapeCenterX=shapeCenterX+meshSpacing[metal3layer]
						shapeCenterX=findTrack(cvLay shapeCenterX (shapeBottom-lineEndSpacing[metal3layer]+0.001) (shapeTop+lineEndSpacing[metal3layer]-0.001) "vertical" trackSpacing[metal3layer] trackWidth[metal3layer] metal3layer net "both")
						shapeLeft=shapeCenterX-metal3minW/2
						shapeRight=shapeLeft+metal3minW
					)
					
					shapeRight=shapeRight-meshSpacing[metal3layer]
					when(metal4shapeRight<shapeRight
						leStretchFig(metal4trunk (shapeRight-metal4shapeRight+stdVia3layer2Enc):0 list(nil nil t t))
					)
				)
				lceExtract(cvLay1)
			)
			
			when(nextRow || singleRowPos=="bottom"
				;;Connect metal4 trunk to gate terms below
				routeDirectiveKey=nil
				sprintf(routeDirectiveKey "%s-%d_%d-BOTTOM_TERM",net~>name,row,nextRow)
				printf("routeDirective:%s %s\n",routeDirectiveKey,routeDirective[routeDirectiveKey])
				when(!member(routeDirectiveKey routeDirective~>?) || routeDirective[routeDirectiveKey]=="CONNECT"
					foreach(instTerm setof(x instTermList rexMatchp(gateTermMatchName x~>name))
						gateTermBBox=gateTermBBoxTable[instTerm]
						printf("inst:%s gate term:%L\n",instTerm~>inst~>name,gateTermBBox)
						gateTermBBoxLeft=bBoxLeft(gateTermBBox)
						gateTermBBoxRight=bBoxRight(gateTermBBox)
						numofFingers=get(instTerm~>inst numofFingersParam)
						when(stringp(numofFingers) numofFingers=atoi(numofFingers))
						when(numofFingers<=2
							gateTermBBoxLeft=bBoxLeft(gateTermBBox)-shortGateTermExtension
							gateTermBBoxRight=bBoxRight(gateTermBBox)+shortGateTermExtension
						)
						
						;;From center to left
						shapeCenterX=car(centerBox(gateTermBBox))
						shapeCenterX=snap(shapeCenterX trackSpacing[metal3layer])
						shapeBottom=bBoxBottom(gateTermBBox)-stdVia2layer2Enc
						shapeTop=metal4shapeTop+stdVia3layer1Enc-(trackWidth[metal4layer]-via3size)/2
						shapeCenterX=findTrack(cvLay shapeCenterX (shapeBottom-lineEndSpacing[metal3layer]+0.001) (shapeTop+lineEndSpacing[metal3layer]-0.001) "vertical" trackSpacing[metal3layer] trackWidth[metal3layer] metal3layer net "left")
						shapeLeft=shapeCenterX-metal3minW/2
						shapeRight=shapeLeft+metal3minW
						when(shapeLeft<gateTermBBoxLeft+stdVia1layer1Enc
							shapeCenterX=shapeCenterX+trackSpacing[metal3layer]
							shapeCenterX=findTrack(cvLay shapeCenterX (shapeBottom-lineEndSpacing[metal3layer]+0.001) (shapeTop+lineEndSpacing[metal3layer]-0.001) "vertical" trackSpacing[metal3layer] trackWidth[metal3layer] metal3layer net "right")
							shapeLeft=shapeCenterX-metal3minW/2
							shapeRight=shapeLeft+metal3minW
							when(shapeRight>gateTermBBoxRight error("No metal3 track available for gate term of %s",instTerm~>inst~>name))
						)
						shapeCenterXfirst=shapeCenterX
						while(shapeLeft>gateTermBBoxLeft+stdVia1layer1Enc
							dbCreateRect(cvLay list(metal3layer "drawing") list(shapeLeft:shapeBottom shapeRight:shapeTop))
		
							if(vncap then
								via3shapeBottom=metal4shapeBottom+stdVia3layer2Enc
								via3shapeTop=via3shapeBottom+via3size
								dbCreateRect(cvLay list(via3layer "drawing") list(shapeLeft:via3shapeBottom shapeRight:via3shapeTop))
								via3shapeBottom=via3shapeTop+via3minEdgeSpacing
								via3shapeTop=via3shapeBottom+via3size
								dbCreateRect(cvLay list(via3layer "drawing") list(shapeLeft:via3shapeBottom shapeRight:via3shapeTop))
							else
								via3shapeBottom=metal4shapeBottom+metal4minW/2-via3size/2
								via3shapeTop=via3shapeBottom+via3size
								dbCreateRect(cvLay list(via3layer "drawing") list(shapeLeft:via3shapeBottom shapeRight:via3shapeTop))
							)
							
							via2shapeBottom=bBoxBottom(gateTermBBox)
							via2shapeTop=via2shapeBottom+via3size
							dbCreateRect(cvLay list(via2layer "drawing") list(shapeLeft:via2shapeBottom shapeRight:via2shapeTop))
							
							shapeCenterX=shapeCenterX-meshSpacing[metal3layer]
							shapeCenterX=findTrack(cvLay shapeCenterX (shapeBottom-lineEndSpacing[metal3layer]+0.001) (shapeTop+lineEndSpacing[metal3layer]-0.001) "vertical" trackSpacing[metal3layer] trackWidth[metal3layer] metal3layer net "both")
							shapeLeft=shapeCenterX-metal3minW/2
							shapeRight=shapeLeft+metal3minW
						)
						lceExtract(cvLay1)
						
						;;From center to right
						shapeCenterX=shapeCenterXfirst+meshSpacing[metal3layer]
						shapeCenterX=findTrack(cvLay shapeCenterX (shapeBottom-lineEndSpacing[metal3layer]+0.001) (shapeTop+lineEndSpacing[metal3layer]-0.001) "vertical" trackSpacing[metal3layer] trackWidth[metal3layer] metal3layer net "both")
						shapeLeft=shapeCenterX-metal3minW/2
						shapeRight=shapeLeft+metal3minW
						while(shapeRight<gateTermBBoxRight-stdVia1layer1Enc
							dbCreateRect(cvLay list(metal3layer "drawing") list(shapeLeft:shapeBottom shapeRight:shapeTop))
		
							if(vncap then
								via3shapeBottom=metal4shapeBottom+stdVia3layer2Enc
								via3shapeTop=via3shapeBottom+via3size
								dbCreateRect(cvLay list(via3layer "drawing") list(shapeLeft:via3shapeBottom shapeRight:via3shapeTop))
								via3shapeBottom=via3shapeTop+via3minEdgeSpacing
								via3shapeTop=via3shapeBottom+via3size
								dbCreateRect(cvLay list(via3layer "drawing") list(shapeLeft:via3shapeBottom shapeRight:via3shapeTop))
							else
								via3shapeBottom=metal4shapeBottom+metal4minW/2-via3size/2
								via3shapeTop=via3shapeBottom+via3size
								dbCreateRect(cvLay list(via3layer "drawing") list(shapeLeft:via3shapeBottom shapeRight:via3shapeTop))
							)
							
							via2shapeBottom=bBoxBottom(gateTermBBox)
							via2shapeTop=via2shapeBottom+via3size
							dbCreateRect(cvLay list(via2layer "drawing") list(shapeLeft:via2shapeBottom shapeRight:via2shapeTop))
							
							shapeCenterX=shapeCenterX+meshSpacing[metal3layer]
							shapeCenterX=findTrack(cvLay shapeCenterX (shapeBottom-lineEndSpacing[metal3layer]+0.001) (shapeTop+lineEndSpacing[metal3layer]-0.001) "vertical" trackSpacing[metal3layer] trackWidth[metal3layer] metal3layer net "both")
							shapeLeft=shapeCenterX-metal3minW/2
							shapeRight=shapeLeft+metal3minW
						)
						lceExtract(cvLay1)
					);;foreach each gate term
				);;Connect metal4 trunk to gate terms below
			)
			
			when(!singleRow || singleRowPos=="top"
				;;Connect metal4 trunk to gate terms above
				routeDirectiveKey=nil
				sprintf(routeDirectiveKey "%s-%d_%d-TOP_TERM",net~>name,row,nextRow)
				printf("routeDirectiveKey:%s\n",routeDirectiveKey)
				when(!member(routeDirectiveKey routeDirective~>?) || routeDirective[routeDirectiveKey]=="CONNECT"
					foreach(instTerm setof(x instTermList2 rexMatchp(gateTermMatchName x~>name))
						gateTermBBox=gateTermBBoxTable[instTerm]
						printf("inst:%s gate term:%L\n",instTerm~>inst~>name,gateTermBBox)
						gateTermBBoxLeft=bBoxLeft(gateTermBBox)
						gateTermBBoxRight=bBoxRight(gateTermBBox)
						numofFingers=get(instTerm~>inst numofFingersParam)
						when(stringp(numofFingers) numofFingers=atoi(numofFingers))
						when(numofFingers<=2
							gateTermBBoxLeft=bBoxLeft(gateTermBBox)-shortGateTermExtension
							gateTermBBoxRight=bBoxRight(gateTermBBox)+shortGateTermExtension
						)
						
						;;From center to left
						shapeCenterX=car(centerBox(gateTermBBox))
						shapeCenterX=snap(shapeCenterX trackSpacing[metal3layer])
						shapeTop=bBoxTop(gateTermBBox)+stdVia2layer2Enc
						shapeBottom=metal4shapeBottom-stdVia3layer1Enc+(trackWidth[metal4layer]-via3size)/2
						shapeCenterX=findTrack(cvLay shapeCenterX (shapeBottom-lineEndSpacing[metal3layer]+0.001) (shapeTop+lineEndSpacing[metal3layer]-0.001) "vertical" trackSpacing[metal3layer] trackWidth[metal3layer] metal3layer net "left")
						shapeLeft=shapeCenterX-metal3minW/2
						shapeRight=shapeLeft+metal3minW
						when(shapeLeft<gateTermBBoxLeft+stdVia1layer1Enc
							shapeCenterX=shapeCenterX+trackSpacing[metal3layer]
							shapeCenterX=findTrack(cvLay shapeCenterX (shapeBottom-lineEndSpacing[metal3layer]+0.001) (shapeTop+lineEndSpacing[metal3layer]-0.001) "vertical" trackSpacing[metal3layer] trackWidth[metal3layer] metal3layer net "right")
							shapeLeft=shapeCenterX-metal3minW/2
							shapeRight=shapeLeft+metal3minW
							when(shapeRight>gateTermBBoxRight error("No metal3 track available for gate term of %s",instTerm~>inst~>name))
						)
						shapeCenterXfirst=shapeCenterX
						while(shapeLeft>gateTermBBoxLeft+stdVia1layer1Enc
							dbCreateRect(cvLay list(metal3layer "drawing") list(shapeLeft:shapeBottom shapeRight:shapeTop))
		
							if(vncap then
								via3shapeBottom=metal4shapeBottom+stdVia3layer2Enc
								via3shapeTop=via3shapeBottom+via3size
								dbCreateRect(cvLay list(via3layer "drawing") list(shapeLeft:via3shapeBottom shapeRight:via3shapeTop))
								via3shapeBottom=via3shapeTop+via3minEdgeSpacing
								via3shapeTop=via3shapeBottom+via3size
								dbCreateRect(cvLay list(via3layer "drawing") list(shapeLeft:via3shapeBottom shapeRight:via3shapeTop))
							else
								via3shapeBottom=metal4shapeBottom+metal4minW/2-via3size/2
								via3shapeTop=via3shapeBottom+via3size
								dbCreateRect(cvLay list(via3layer "drawing") list(shapeLeft:via3shapeBottom shapeRight:via3shapeTop))
							)
							
							via2shapeBottom=bBoxBottom(gateTermBBox)
							via2shapeTop=via2shapeBottom+via3size
							dbCreateRect(cvLay list(via2layer "drawing") list(shapeLeft:via2shapeBottom shapeRight:via2shapeTop))
							
							shapeCenterX=shapeCenterX-meshSpacing[metal3layer]
							shapeCenterX=findTrack(cvLay shapeCenterX (shapeBottom-lineEndSpacing[metal3layer]+0.001) (shapeTop+lineEndSpacing[metal3layer]-0.001) "vertical" trackSpacing[metal3layer] trackWidth[metal3layer] metal3layer net "both")
							shapeLeft=shapeCenterX-metal3minW/2
							shapeRight=shapeLeft+metal3minW
						)
						lceExtract(cvLay1)
						
						;;From center to right
						shapeCenterX=shapeCenterXfirst+meshSpacing[metal3layer]
						shapeCenterX=findTrack(cvLay shapeCenterX (shapeBottom-lineEndSpacing[metal3layer]+0.001) (shapeTop+lineEndSpacing[metal3layer]-0.001) "vertical" trackSpacing[metal3layer] trackWidth[metal3layer] metal3layer net "both")
						shapeLeft=shapeCenterX-metal3minW/2
						shapeRight=shapeLeft+metal3minW
						while(shapeRight<gateTermBBoxRight-stdVia1layer1Enc
							dbCreateRect(cvLay list(metal3layer "drawing") list(shapeLeft:shapeBottom shapeRight:shapeTop))
		
							if(vncap then
								via3shapeBottom=metal4shapeBottom+stdVia3layer2Enc
								via3shapeTop=via3shapeBottom+via3size
								dbCreateRect(cvLay list(via3layer "drawing") list(shapeLeft:via3shapeBottom shapeRight:via3shapeTop))
								via3shapeBottom=via3shapeTop+via3minEdgeSpacing
								via3shapeTop=via3shapeBottom+via3size
								dbCreateRect(cvLay list(via3layer "drawing") list(shapeLeft:via3shapeBottom shapeRight:via3shapeTop))
							else
								via3shapeBottom=metal4shapeBottom+metal4minW/2-via3size/2
								via3shapeTop=via3shapeBottom+via3size
								dbCreateRect(cvLay list(via3layer "drawing") list(shapeLeft:via3shapeBottom shapeRight:via3shapeTop))
							)
							
							via2shapeBottom=bBoxBottom(gateTermBBox)
							via2shapeTop=via2shapeBottom+via3size
							dbCreateRect(cvLay list(via2layer "drawing") list(shapeLeft:via2shapeBottom shapeRight:via2shapeTop))
							
							shapeCenterX=shapeCenterX+meshSpacing[metal3layer]
							shapeCenterX=findTrack(cvLay shapeCenterX (shapeBottom-lineEndSpacing[metal3layer]+0.001) (shapeTop+lineEndSpacing[metal3layer]-0.001) "vertical" trackSpacing[metal3layer] trackWidth[metal3layer] metal3layer net "both")
							shapeLeft=shapeCenterX-metal3minW/2
							shapeRight=shapeLeft+metal3minW
						)
						lceExtract(cvLay1)
					);;foreach each gate term
				);;Connect metal4 trunk to gate terms above
			)
		);;for each row
		
		;;Trunk-to-trunk connection		
		foreach(routeDirectiveKey routeDirective~>?
			when(rexMatchp(net~>name routeDirectiveKey) && rexMatchp("TRUNK" routeDirectiveKey)
				printf("routeDirectiveKey:%s\n",routeDirectiveKey)
				metal4trunkName=cadr(parseString(routeDirectiveKey "-"))
				printf("metal4trunkName:%s\n",metal4trunkName)
				metal4trunkName2=car(routeDirective[routeDirectiveKey])
				trackName=cadr(routeDirective[routeDirectiveKey])
				viaName=nth((lindex(metalLayerList trackName)-2) viaLayerList)
				printf("metal4trunkName2:%s trackName:%s viaName:%s\n",metal4trunkName2,trackName,viaName)
				metal4trunk=metal4trunkTable[metal4trunkName]
				metal4trunk2=metal4trunkTable[metal4trunkName2]
				printf("metal4trunk:%L metal4trunk2:%L\n",metal4trunk~>bBox,metal4trunk2~>bBox)
				overlapLeft=getBBoxLeft(metal4trunk2)
				overlapRight=getBBoxRight(metal4trunk)
				when(overlapLeft<getBBoxLeft(metal4trunk)
					overlapLeft=getBBoxLeft(metal4trunk)
					overlapRight=getBBoxRight(metal4trunk2)
				)
				printf("overlapLeft:%f overlapRight:%f\n",overlapLeft,overlapRight)
				
				;viaSize=viaSize[viaName]
				shapeCenterX=overlapLeft+viaSize[viaName]/2
				shapeCenterX=snap(shapeCenterX trackSpacing[trackName] ?direction "right")
				metal4trunkCenterY=cadr(centerBox(metal4trunk~>bBox))
				metal4trunk2CenterY=cadr(centerBox(metal4trunk2~>bBox))
				if(metal4trunkCenterY<metal4trunk2CenterY then
					shapeBottom=metal4trunkCenterY-viaSize[viaName]/2-viaLayer2enc[viaName]
					shapeTop=metal4trunk2CenterY+viaSize[viaName]/2+viaLayer2enc[viaName]
					lowerTrunkCenterY=metal4trunkCenterY
					upperTrunkCenterY=metal4trunk2CenterY
				else
					shapeBottom=metal4trunk2CenterY-viaSize[viaName]/2-viaLayer2enc[viaName]
					shapeTop=metal4trunkCenterY+viaSize[viaName]/2+viaLayer2enc[viaName]
					lowerTrunkCenterY=metal4trunk2CenterY
					upperTrunkCenterY=metal4trunkCenterY
				)
				shapeCenterX=findTrack(cvLay shapeCenterX (shapeBottom-lineEndSpacing[trackName]+0.001) (shapeTop+lineEndSpacing[trackName]-0.001) "vertical" trackSpacing[trackName] trackWidth[trackName] trackName net "right")
				while(shapeCenterX<overlapRight-viaSize[viaName]/2
					printf("shapeCenterX:%f\n",shapeCenterX)
					shapeLeft=shapeCenterX-trackWidth[trackName]/2
					shapeRight=shapeLeft+trackWidth[trackName]
					dbCreateRect(cvLay list(trackName "drawing") list(shapeLeft:shapeBottom shapeRight:shapeTop))		
					
					viaShapeBottom=shapeBottom+viaLayer2enc[viaName]
					viaShapeTop=viaShapeBottom+viaSize[viaName]
					dbCreateRect(cvLay list(viaName "drawing") list(shapeLeft:viaShapeBottom shapeRight:viaShapeTop))
					
					when(trackName==metal7layer
						shapeLeft2=shapeLeft-viaLayer1encMinArea[viaName]
						shapeRight2=shapeRight+viaLayer1encMinArea[viaName]
						dbCreateRect(cvLay list(metal6layer "drawing") list(shapeLeft2:viaShapeBottom shapeRight2:viaShapeTop))
						
						viaShapeLeft=shapeCenterX-viaSize[via5layer]/2
						viaShapeRight=viaShapeLeft+viaSize[via5layer]
						viaShapeBottom=lowerTrunkCenterY-viaSize[via5layer]/2
						viaShapeTop=viaShapeBottom+viaSize[via5layer]
						dbCreateRect(cvLay list(via5layer "drawing") list(viaShapeLeft:viaShapeBottom viaShapeRight:viaShapeTop))
						
						shapeLeft2=shapeCenterX-trackWidth[metal5layer]/2
						shapeRight2=shapeLeft2+trackWidth[metal5layer]
						metal5shapeBottom=viaShapeBottom-viaLayer1encMinArea[via5layer]
						metal5shapeTop=viaShapeTop+viaLayer1encMinArea[via5layer]
						dbCreateRect(cvLay list(metal5layer "drawing") list(shapeLeft2:metal5shapeBottom shapeRight2:metal5shapeTop))
						
						viaShapeLeft=shapeCenterX-viaSize[via4layer]/2
						viaShapeRight=viaShapeLeft+viaSize[via4layer]
						viaShapeBottom=lowerTrunkCenterY-viaSize[via4layer]/2
						viaShapeTop=viaShapeBottom+viaSize[via4layer]
						dbCreateRect(cvLay list(via4layer "drawing") list(viaShapeLeft:viaShapeBottom viaShapeRight:viaShapeTop))
					)
					
					viaShapeTop=shapeTop-viaLayer2enc[viaName]
					viaShapeBottom=viaShapeTop-viaSize[viaName]
					dbCreateRect(cvLay list(viaName "drawing") list(shapeLeft:viaShapeBottom shapeRight:viaShapeTop))
					
					when(trackName==metal7layer
						shapeLeft2=shapeLeft-viaLayer1encMinArea[viaName]
						shapeRight2=shapeRight+viaLayer1encMinArea[viaName]
						dbCreateRect(cvLay list(metal6layer "drawing") list(shapeLeft2:viaShapeBottom shapeRight2:viaShapeTop))
						
						viaShapeLeft=shapeCenterX-viaSize[via5layer]/2
						viaShapeRight=viaShapeLeft+viaSize[via5layer]
						viaShapeBottom=upperTrunkCenterY-viaSize[via5layer]/2
						viaShapeTop=viaShapeBottom+viaSize[via5layer]
						dbCreateRect(cvLay list(via5layer "drawing") list(viaShapeLeft:viaShapeBottom viaShapeRight:viaShapeTop))
						
						shapeLeft2=shapeCenterX-trackWidth[metal5layer]/2
						shapeRight2=shapeLeft2+trackWidth[metal5layer]
						metal5shapeBottom=viaShapeBottom-viaLayer1encMinArea[via5layer]
						metal5shapeTop=viaShapeTop+viaLayer1encMinArea[via5layer]
						dbCreateRect(cvLay list(metal5layer "drawing") list(shapeLeft2:metal5shapeBottom shapeRight2:metal5shapeTop))
						
						viaShapeLeft=shapeCenterX-viaSize[via4layer]/2
						viaShapeRight=viaShapeLeft+viaSize[via4layer]
						viaShapeBottom=upperTrunkCenterY-viaSize[via4layer]/2
						viaShapeTop=viaShapeBottom+viaSize[via4layer]
						dbCreateRect(cvLay list(via4layer "drawing") list(viaShapeLeft:viaShapeBottom viaShapeRight:viaShapeTop))
					)
					
					shapeCenterX=shapeCenterX+meshSpacing[trackName]
					shapeCenterX=findTrack(cvLay shapeCenterX (shapeBottom-lineEndSpacing[trackName]+0.001) (shapeTop+lineEndSpacing[trackName]-0.001) "vertical" trackSpacing[trackName] trackWidth[trackName] trackName net "both")
				)
			)
		);;Trunk-to-trunk connection
		
		;;Trim metal4 trunks
		foreach(metal4trunk metal4trunkList
			objectList=dbGetTrueOverlaps(cvLay metal4trunk~>bBox list(via3layer "drawing"))
			objectList=append(objectList dbGetTrueOverlaps(cvLay metal4trunk~>bBox list(via4layer "drawing")))
			objectList=append(objectList dbGetTrueOverlaps(cvLay metal4trunk~>bBox list(metal4layer "pin")))
			objectList=append(objectList dbGetTrueOverlaps(cvLay metal4trunk~>bBox list(metal4layer "drawing")))
			objectList=remove(metal4trunk objectList)
			objectList=sortObjects(objectList)
			
			leftMostObject=car(objectList)
			float1=getBBoxLeft(leftMostObject)
			when(leftMostObject~>layerName==via3layer float1=float1-stdVia3layer2Enc)
			when(leftMostObject~>layerName==via4layer float1=float1-stdVia4layer1Enc)
			metal4trunkLeft=getBBoxLeft(metal4trunk)
			printf("metal4trunkLeft:%f float1:%f\n",metal4trunkLeft,float1)
			when(metal4trunkLeft<float1
				leStretchFig(metal4trunk (float1-metal4trunkLeft):0 list(t t nil nil))
			)
			
			rightMostObject=car(last(objectList))
			float1=getBBoxRight(rightMostObject)
			when(rightMostObject~>layerName==via3layer float1=float1+stdVia3layer2Enc)
			when(rightMostObject~>layerName==via4layer float1=float1+stdVia4layer1Enc)
			metal4trunkRight=getBBoxRight(metal4trunk)
			printf("metal4trunkRight:%f float1:%f\n",metal4trunkRight,float1)
			when(metal4trunkRight>float1
				leStretchFig(metal4trunk -(metal4trunkRight-float1):0 list(nil nil t t))
			)
			
			metal4trunkLength=getBBoxRight(metal4trunk)-getBBoxLeft(metal4trunk)
			metal4trunkWidth=getBBoxTop(metal4trunk)-getBBoxBottom(metal4trunk)
			when(metal4minArea>(metal4trunkLength*metal4trunkWidth)
				float1=(metal4minArea/metal4trunkWidth-metal4trunkLength)/2+0.001
				leStretchFig(metal4trunk -float1:0 list(t t nil nil))
				leStretchFig(metal4trunk float1:0 list(nil nil t t))
			)
			
		)
		
		printf("%s\n",net~>name)
		printf("routing done for %s\n",net~>name)
	);;let
);;procedure internalRoute3

procedure(sortObjects(objectList)
	prog((object sortedObjectList bBoxLeftMost bBoxLeft i j)
		sortedObjectList=list()
		j=length(objectList)-1
		for(i 0 j
			bBoxLeftMost=1000
			foreach(object objectList
				bBoxLeft=getBBoxLeft(object)
				when(bBoxLeft<bBoxLeftMost
					bBoxLeftMost=bBoxLeft
					leftMostObject=object
				)
			)
			sortedObjectList=append(sortedObjectList list(leftMostObject))
			objectList=remove(leftMostObject objectList)
		)
		return(sortedObjectList)
	);;prog
);;procedure sortObjects

procedure(snap(position trackSpacing @key (direction nil))
	prog((positionInt delta)
		positionInt=int(position*1000)
		positionFloat=float(positionInt)/1000
		delta=float(mod(positionInt int(trackSpacing*1000)))/1000
		if(direction then
			cond(
				(direction=="left" || direction=="bottom" return(positionFloat-delta))
				(direction=="right" || direction=="top" return(positionFloat+trackSpacing-delta))
			)
		else
			if(delta<trackSpacing/2 then
				return(positionFloat-delta)
			else
				return(positionFloat+trackSpacing-delta)
			)
		)
	);;prog
);;procedure snap

procedure(findTrack(cvLay shapeCenter shapeLeftBottom shapeRightTop trackDirection trackSpacing trackWidth layer net searchDirection)
	prog((shapeCenter2 shapeLeft shapeBottom shapeRight shapeTop done list1 shape shapeBBox multiplier sign)
		if(trackDirection=="vertical" then
			shapeBottom=shapeLeftBottom
			shapeTop=shapeRightTop
			shapeLeft=shapeCenter-trackWidth/2
			shapeRight=shapeLeft+trackWidth
		else
			shapeLeft=shapeLeftBottom
			shapeRight=shapeRightTop
			shapeBottom=shapeCenter-trackWidth/2
			shapeTop=shapeBottom+trackWidth
		)
		
		done=nil
		multiplier=1
		sign=1
		when(searchDirection=="left" || searchDirection=="bottom"
			sign=-1
		)
		printf("findTrack:shapeCenter:%f\n",shapeCenter)
		while(!done
			printf("bbox:%L\n",list(shapeLeft shapeBottom shapeRight shapeTop))
			list1=dbGetTrueOverlaps(cvLay list(shapeLeft:shapeBottom shapeRight:shapeTop) list(layer "drawing"))
			list1=append(list1 dbGetTrueOverlaps(cvLay list(shapeLeft:shapeBottom shapeRight:shapeTop) list(layer "pin")))
			done=t
			printf("findTrack:list1:%L\n",list1)
			;lceExtract(cvLay)
			foreach(shape list1
				;when(listp(shape) shape=car(shape))
				if(shape~>net then
					when(shape~>net!=net
						printf("findTrack:chk %s %s\n",net~>name,layer)
						printf("shape net:%s\n",shape~>net~>name)
						done=nil
					)
				else
					error("Found a %s shape %L that is not on any net\n",layer,shape~>bBox)
				)
			)
			when(!done
				shapeCenter=shapeCenter+trackSpacing*multiplier*sign
				printf("shapeCenter:%f\n",shapeCenter)
				if(trackDirection=="vertical" then
					shapeLeft=shapeCenter-trackWidth/2
					shapeRight=shapeLeft+trackWidth
				else
					shapeBottom=shapeCenter-trackWidth/2
					shapeTop=shapeBottom+trackWidth
				)
				
				when(searchDirection=="both"
					multiplier=multiplier+1
					sign=sign*-1
				)
			)
		)

		;;Merge with adjacent vertical track on the same net (if any)
		if(trackDirection=="vertical" then
			shapeCenter2=shapeCenter-trackSpacing
			shapeLeft=shapeCenter2-trackWidth/2
			shapeRight=shapeLeft+trackWidth
			list1=dbGetTrueOverlaps(cvLay list(shapeLeft:shapeBottom shapeRight:shapeTop) list(layer "drawing"))
			when(length(list1)==1 && car(list1)~>net==net
				return(shapeCenter2)
			)
			shapeCenter2=shapeCenter+trackSpacing
			shapeLeft=shapeCenter2-trackWidth/2
			shapeRight=shapeLeft+trackWidth
			list1=dbGetTrueOverlaps(cvLay list(shapeLeft:shapeBottom shapeRight:shapeTop) list(layer "drawing"))
			when(length(list1)==1 && car(list1)~>net==net
				return(shapeCenter2)
			)
		)
		
		return(shapeCenter)
	);;prog
);;procedure findTrack
