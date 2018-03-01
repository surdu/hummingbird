macroScript Hummingbird category:"CVDS"
(

camCollection = undefined
btgraph= undefined
struct graphDataType (value,inTangent,outTangent)

rollout btVFB "Hummingbird VFB"
(
	bitmap preview "Preview" pos:[5,7] width:renderWidth height:renderHeight
)

rollout btCurve "Hummingbird curve editor" width:700 height:310
(
	CurveControl timeCurve "" pos:[3,7] width:690 height:290 x_range:[1,200] y_range:[1,200] numCurves:2
	
	global btgraph
	
	function restoreGraph graphData =
	(
		btCurve.timeCurve.curves[1].numPoints=graphData.count
		for f=1 to graphData.count do
			(
				btCurve.timeCurve.curves[1].points[f].value=graphData[f].value
				btCurve.timeCurve.curves[1].points[f].inTangent=graphData[f].inTangent
				btCurve.timeCurve.curves[1].points[f].outTangent=graphData[f].outTangent
			)
	)
		
	on btCurve open do
	(
		if camCollection!=undefined Then
			timeCurve.x_range=[0,camCollection.count+1]
		else
			timeCurve.x_range=[0,100]
		timeCurve.y_range=[0,AnimationRange.end.frame]
		btCurve.timeCurve.numCurves=2
		btCurve.timeCurve.curves[1].name="Bullet time timing"
		btCurve.timeCurve.curves[1].style=#solid
		btCurve.timeCurve.curves[1].color=red
		
		if btGraph==undefined Then
			(
				btCurve.timeCurve.curves[1].numPoints=2
				btCurve.timeCurve.curves[1].points[1].value=[0,AnimationRange.end.frame/2]
				btCurve.timeCurve.curves[1].points[2].value=[100,AnimationRange.end.frame/2]
			)
		else
			restoreGraph(btGraph)
			
	
		timeCurve.curves[2].numPoints=0
		zoom timeCurve #all
	)
	on btCurve close  do
	(
		global btgraph
		btGraph=btCurve.timeCurve.curves[1].points
	)
)

rollout aboutRollout "About" width:200 height:250
(
    label lbl3 "Hummingbird v1.0 BETA 1" pos:[41,4] width:166 height:17
	label lbl4 "Created by" pos:[75,22] width:62 height:17
	bitmap preview "Logo" pos:[25,38] width:150 height:80 fileName:"cvds_logo.bmp"
	label pathText "For updates please check" pos:[40,130] width:166 height:17
	HyperLink cvds_link "www.cvds.ro" pos:[65,151] width:77 height:15 address:"http://www.cvds.ro"
)
rollout renderRollout "Render" width:200 height:400
(
	GroupBox grp28 "Output directory" pos:[10,239] width:179 height:66
	button openRender "Open render dialog" pos:[17,371] width:102 height:20
	button renderBtn "RENDER" pos:[122,371] width:60 height:20 enabled:false
	label pathText "Not specified ..." pos:[17,259] width:166 height:17
	button selDir "Select directory" pos:[90,282] width:91 height:18
	
	
	GroupBox grp31 "Timing" pos:[10,10] width:179 height:94
	radiobuttons timingMode "" pos:[53,34] width:101 height:32 enabled:false labels:#("Use single frame", "Use curve")
	spinner btFrame "Frame:" pos:[65,80] width:73 height:16 enabled:false
	button editCurve "Edit curve" pos:[128,15] width:55 height:22 visible:false
	
	GroupBox grp6 "Output format" pos:[11,314] width:179 height:45
	radiobuttons outputFormat "" pos:[35,332] width:46 height:48 labels:#(".bmp", ".jpeg", ".tga")
	
	
	button loadCurve "Load ..." pos:[73,15] width:50 height:22 visible:false
	button saveCurve "Save..." pos:[16,15] width:50 height:22 visible:false
	groupBox previwFrame "Preview" pos:[10,113] width:179 height:120
	button previewBtn "Preview" pos:[106,200] width:73 height:20  enabled:false
	checkbox minViewChk "Maximize viewport" pos:[29,137] width:114 height:20 checked:true  enabled:false
    checkbox hideIcons "Hide camera set icons" pos:[29,160] width:125 height:20 checked:true  enabled:false

	on previewBtn pressed do
	(
        count=camCollection.count        
	    currentLayout = viewport.getLayout()
	    print currentLayout
	    max time start
	    progressStart "Preview bullet-time"
		escapeEnable=true
		--viewport.SetLayout = #layout_1
        f=0        
		while ( (f<count-1) and (not getProgressCancel()) ) do        
        (
            progress=100.0*f/count
            progressUpdate progress

			case timingMode.state of
			(
				1: bulletTime=btFrame.value
				2: bulletTime=getValue btCurve.timeCurve.curves[1] f f
			)
            
            sliderTime=bulletTime
            viewport.setCamera camCollection[f+1]
            f+=1            
        )
        progressEnd()
        --viewport.setLayout() currentLayout
	)

	function saveGraph graphData outFile =
	(
		file = createFile outFile
		for f=1 to graphData.count do
			(
				plotData=""
				plotData+=(graphData[f].value[1] as string)+" "+(graphData[f].value[2] as string)+" "
				plotData+=(graphData[f].inTangent[1] as string)+" "+(graphData[f].inTangent[2] as string)+" "
				plotData+=(graphData[f].outTangent[1] as string)+" "+(graphData[f].outTangent[2] as string)+"\n"
				format plotData to:file
			)		
		
		close file
	)

	function loadGraph inFile =
	(
		file = openFile inFile mode:"r"
		graphData=#() 
		while not eof file do
			(
				data=readLine file
				result=filterString data " "
				plotData = graphDataType value:[0,0] inTangent:[0,0] outTangent:[0,0]
				plotData.value[1]=result[1] as float
				plotData.value[2]=result[2] as float
				plotData.inTangent[1]=result[3] as float
				plotData.inTangent[2]=result[4] as float
				plotData.outTangent[1]=result[5] as float
				plotData.outTangent[2]=result[6] as float
				append graphData plotData
			)				
		close file		
        return graphData
	)

	
	on renderRollout open do
	(
		animRange=[AnimationRange.start.frame,AnimationRange.end.frame,AnimationRange.end.frame/2]
		editCurve.pos=[128,76]
		loadCurve.pos=[73,76]
		saveCurve.pos=[16,76]
		btFrame.range=animRange
		global renderPath=undefined
	
	)
	on openRender pressed do
	(
		renderscenedialog.open()
	--		print (getValue btCurve.timeCurve.curves[1] 5 5)
	)
	on renderBtn pressed do
	(
		if renderPath==undefined Then
			messageBox "You must set a path to save the animation!" beep:true
		else
		(
			count=camCollection.count
			progressStart "Render bullet-time"
			escapeEnable=true
			createDialog btVFB width:(renderWidth+10) height:(renderHeight+10)
	
			case outputFormat.state of
			(
				1: extension=".bmp"
				2: extension=".jpg"
				3: extension=".tga"
			)
			
	--			for f=0 to count-1 do
			f=0
			while ( (f<count-1) and (not getProgressCancel()) ) do
				(
					progress=100.0*f/count
		
				  --BUG: Exception is raised here if ESC is pressed 
					progressUpdate progress 				
		
					outFile=renderPath+"\\"+camCollection[f+1].name+extension
					case timingMode.state of
					(
						1: bulletTime=btFrame.value
						2: bulletTime=getValue btCurve.timeCurve.curves[1] f f
					)
					gc()
					btVFB.preview.bitmap=render camera:camCollection[f+1] frame:bulletTime progressbar:false vfb:false outputfile:outFile
					f+=1					
				)
			progressEnd()
			destroyDialog btVFB
		)
	)
	on selDir pressed do
	(
		path=getSavePath()
		if path!=undefined Then
			(
				renderPath=path
				pathText.caption=path
			)
	
	)
	on timingMode changed stat do
	(
		case timingMode.state of
		(
			1:(
				btFrame.visible=true
				editCurve.visible=false
				loadCurve.visible=false
				saveCurve.visible=false
			)
			2:(
				btFrame.visible=false
				editCurve.visible=true
				loadCurve.visible=true
				saveCurve.visible=true
				if btGraph==undefined Then 
					createDialog btCurve modal:true						
			)
		)
	)
	on editCurve pressed do
	(
		createDialog btCurve modal:true
	)
	on loadCurve pressed do
	(
		result = GetOpenFileName caption:"File to load curve from" types:"Hummingbird curve(*.hbc)|*.hbc"
		if result != undefined Then
		(
			global btGraph
			btGraph = loadGraph result
			createDialog btCurve modal:true
		)
	)
	on saveCurve pressed do
	(
		result = GetSaveFileName caption:"File to save curve" types:"Hummingbird curve(*.hbc)|*.hbc"
		if result != undefined Then
		(
			global btGraph
			saveGraph btGraph result
		)
	)
)
rollout Form1 "Main" width:200 height:734
(
	function camFilter obj =
	(
		return (superClassOf obj == camera)
	)

	function growColor value step =
	(
		if ((value<255-step) and (value>=0+step)) or value==255 or value==0 Then
			value+=step
		else
			if step>0 Then
				value=0
			else
				value=255
		return value
	)	

	function enableAftersetupItems =
	(
		renderRollout.renderBtn.enabled=true
		renderRollout.timingMode.enabled=true
		renderRollout.btFrame.enabled=true
        renderRollout.previewBtn.enabled=true
        -- N/A in BETA version. Comming soon
        --renderRollout.minViewChk.enabled=true
        --renderRollout.hideIcons.enabled=true  
	)

	pickbutton pickCam "Pick cammera" pos:[42,37] width:120 height:20 message:"Pick a cammera" filter:camFilter
	pickbutton pickSeq "Pick camera set" pos:[42,84] width:120 height:20 filter:camFilter
	button prepare "Create camera setup" pos:[37,332] width:123 height:20 enabled:false toolTip:"Create camera set from selected camera's animation"
	label lbl3 "Camera setup:" pos:[68,67] width:69 height:13
	label lbl2 "Camera:" pos:[82,21] width:40 height:13
	

--  Time frame
	spinner tStart "Start:" pos:[28,146] width:70 height:16 range:[0,100,0] type:#integer scale:1
	spinner tEnd "End:" pos:[114,146] width:70 height:16 range:[0,100,0] type:#integer scale:1
	button allBtn "Entire animation" pos:[55,173] width:87 height:18
	
	GroupBox grp8 "Source selection" pos:[10,7] width:183 height:105
	GroupBox grp9 "Camera setup" pos:[10,123] width:179 height:239
	colorPicker color1 "Color 1" pos:[24,269] width:58 height:23 enabled:true color:(color 255 255 0)
	colorPicker color2 "Color 2" pos:[112,269] width:58 height:23 enabled:true color:(color 255 0 0)
	
	radiobuttons colorMode "Camera setup color:" pos:[51,202] width:89 height:62 labels:#("Same color", "Gradient color", "Random color") default:2
	checkbox groupChk "Group setup" pos:[57,303] width:81 height:20 checked:true
	
	on Form1 open do
	(
		startRange=[AnimationRange.start.frame,AnimationRange.end.frame-1,AnimationRange.start.frame]
		endRange=[AnimationRange.start.frame+1,AnimationRange.end.frame,AnimationRange.end.frame]
		
		tStart.range=startRange
		tEnd.range=endRange
		
		global btGraph=undefined
		global camCollection = #()
	)
	on pickCam picked obj do
	(
		global cammera=obj
		pickCam.caption="< "+obj.name+" >"
		prepare.enabled=true
	)
	on pickSeq picked obj do
	(
		 chunks=filterString obj.name " "
		 name=""
		 if (chunks.count>2) Then
			for f=1 to chunks.count-1 do
				if (f!=1) Then
					name+=" "+chunks[f]
				else
					name+=chunks[f]
		else
			name=chunks[1]
		
		global camCollection
		camCollection=#()
		namePattern=(name as string)+"*"
		for item in $* do
		if (matchPattern item.name pattern:namePattern) and (superClassOf item == camera) Then
			append camCollection item
	
		if (camCollection.count<2) Then
			(
				messageBox ("Selected cammera ("+obj.name+") is not part of a camera setup.")
				camCollection = #()
				renderRollout.renderBtn.enabled=false
				pickSeq.caption="Pick camera setup"
			)
		else
			(
				enableAftersetupItems()

				pickSeq.caption=name
			)
	
	)
	on prepare pressed do
	(
		gradientColor=copy color1.color
		
		count=tEnd.value-tStart.value
		redStep=(color2.color.red-color1.color.red)/count
		greenStep=(color2.color.green-color1.color.green)/count
		blueStep=(color2.color.blue-color1.color.blue)/count
		
		progressStart "Camera setup progress"
		escapeEnable=true
		global camCollection
		camCollection= #()
		for t in tStart.value to tEnd.value do at time t
		(
			progress=100.0*t/tEnd.value
	

			if not progressUpdate progress Then exit
			
			maxLen=(tEnd.value as string).count
			curLen=(t as string).count
			addLen=maxLen-curLen
			camNum=""
			for f=0 to addLen-1 do
				camNum+="0"
			camNum+=t as string
			camName="Bullet_Time_Camera "+camNum
			cam=snapshot cammera name:camName
			append camCollection cam
			
			if colorMode.state==1 Then
				cam.wireColor=color1.color
			if colorMode.state==2 Then
				(
					if t==tEnd.value Then 
						gradientColor=copy color2.color
					cam.wireColor=gradientColor
					gradientColor.red=growColor gradientColor.red redStep
					gradientColor.green=growColor gradientColor.green greenStep
					gradientColor.blue=growColor gradientColor.blue blueStep
					
				)
			
		)
		
		if groupChk.checked Then
			group $Bullet_Time_Camera* name:"Bullet Time camera setup"
		enableAftersetupItems()
		progressEnd()
		
	)
	on allBtn pressed do
	(
		tStart.range=[AnimationRange.start.frame,AnimationRange.end.frame-1,AnimationRange.start.frame]
		tEnd.range=[AnimationRange.start.frame+1,AnimationRange.end.frame,AnimationRange.end.frame]		
	)
	on colorMode changed stat do
	(
		case colorMode.state of
		(
			1:(
					color1.visible=true
					color2.visible=false
					color1.pos=[100,269]
					color1.caption="Color"
			  )
			
			2:(
					color1.visible=true
					color2.visible=true
					color1.pos=[61,269]	
					color1.caption="Color 1"		
			  )
			
			3:(
					color1.visible=false
					color2.visible=false
			  )
				
		)

	)
)

MainWindow = newRolloutFloater "Hummingbird v1.0 BETA" 210 600 200 100

addRollout aboutRollout MainWindow rolledUp:false
addRollout Form1 MainWindow rolledUp:false
addRollout renderRollout MainWindow rolledUp:false

--cui.RegisterDialogBar MainWindow
)
