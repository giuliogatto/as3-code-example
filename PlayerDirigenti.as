package  {
	
	import flash.net.*;
	import flash.text.*;
	import flash.display.*;
	import flash.events.*;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import MyGlobal;
	
	
	
	public class PlayerDirigenti extends MovieClip {
		
		
		public function PlayerDirigenti() {
			// constructor code
			var paramList:Object = this.root.loaderInfo.parameters;
			
			// carico i dati esternamente

			var imageLoader:Loader;

			var scudorimosso:int;

			var loader:URLLoader = new URLLoader();  
			loader.dataFormat = URLLoaderDataFormat.VARIABLES;  
			loader.addEventListener(Event.COMPLETE, loading); 


			// QUESTE LE VARIABILI CHE INVIO COL POST
			var urlVariables:URLVariables = new URLVariables();
			urlVariables.idl = paramList["idl"];
			urlVariables.myURL = paramList["myURL"];

			// QUESTE LE VARIABILI CHE RICEVO - sostituire variabili.php o variabili.txt a seconda se si vuole testare in locale o meno
			var urlRequest:URLRequest = new URLRequest("variabili.php");
			urlRequest.method = URLRequestMethod.POST;
			urlRequest.data = urlVariables;

			loader.load(urlRequest);

			
			
			function loading (event:Event):void {  

				// spacchetto e localizzo le variabili caricate
    
				MyGlobal.titololezione=loader.data.titololezione;
				MyGlobal.fileflv="flv/"+loader.data.fileflv;
				MyGlobal.done=loader.data.done;
				MyGlobal.p=loader.data.p;
				MyGlobal.t=loader.data.t;
				MyGlobal.f=loader.data.f;
				MyGlobal.idl=loader.data.idl;
				MyGlobal.ids=paramList["myURL"];
				MyGlobal.numeropunti=loader.data.numeropunti;
				MyGlobal.puntoattuale=loader.data.puntoattuale;				
				MyGlobal.punti = MyGlobal.p.split("*");
				MyGlobal.testi = MyGlobal.t.split("*");
				MyGlobal.filesext = MyGlobal.f.split("*");
				MyGlobal.numeropunti=MyGlobal.punti.length;				
				MyGlobal.puntoattuale=0;				
				 
				if(MyGlobal.done==1)mostramodulo();

			} 
			
			// funzione per rimuovere tutti i children caricati precedentemente in un movieclip
			function removeChildrenOf(mc:MovieClip):void{
				if(mc.numChildren!=0){
					var k:int = mc.numChildren;
					while( k -- )
					{
						mc.removeChildAt( k );
					}
				}
			}
			
			// funzioni per caricamento immagini esterne

			// inserisco il contenitore per l'immagine esterna
			var cont1:imgCont = new imgCont();
			cont1.x=250;
			cont1.y=62;
			addChild(cont1);

			var minuti:int;
			var secondi:int;
			var stringadaag:String;
			
			
			function loadImage(url:String):void {

				// Set properties on my Loader object
				imageLoader = new Loader();
				imageLoader.load(new URLRequest(url));
				imageLoader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, imageLoading);
				imageLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, imageLoaded);

			} 
			function imageLoaded(e:Event):void {
				removeChildrenOf(cont1);
				// Load Image
				cont1.addChild(imageLoader);

			}
			 
			function imageLoading(e:ProgressEvent):void {

				//  TODO: creare un preloader

			}

			// la funzione principale mostramodulo, in pratica il cuore del programma (con la funzione ogniframe che si reitera)

			function mostramodulo(){
				
				// inizializzo video
				
				var video:Video = new Video(180,200);
				video.x=25;
				video.y=60;
				addChild(video);
				
				var nc:NetConnection = new NetConnection();
				nc.connect(null);
				
				var ns:NetStream = new NetStream(nc);
				ns.addEventListener(NetStatusEvent.NET_STATUS, onStatusEvent);
				ns.addEventListener(AsyncErrorEvent.ASYNC_ERROR, asyncErrorHandler);  //  add a listener to the NetStream for any errors that may happen  
				
				
				function onStatusEvent(stat:Object):void
				{
						trace(stat.info.code);
						// il video e' terminato
						
						if(stat.info.code=='NetStream.Play.Stop'){
							MyGlobal.playerstatus=0;
							trace("VIDEO FINITO");

							var testB:nextbuintest = new nextbuintest();
							testB.x = 250;
							testB.y = 240;
							
							testB.addEventListener(MouseEvent.CLICK,testBClick);
							addChild (testB);
							 
							 var t:URLRequest = new URLRequest("javascript:recordlezione('"+MyGlobal.idl+"','"+MyGlobal.ids+"')");;
							 navigateToURL(t,'_self');
							 
						}
						
						
				}
				
				function asyncErrorHandler(Event:AsyncErrorEvent):void  
				{  
					trace("errore");  // this will handle any errors with video playback  
				}
				
				var meta:Object = new Object();
				meta.onMetaData = function(meta:Object)
					{
						trace(meta.duration);
						MyGlobal.duratavideo=int(meta.duration);
					}
				ns.client=meta;
				
				video.attachNetStream(ns);
				
				ns.play(MyGlobal.fileflv);
				ns.pause();
				MyGlobal.playerstatus=0;
				
				
				
				
				
				addEventListener(Event.ENTER_FRAME, ogniFrame);

				// la funzione che viene eseguita ad ogni frame del video
				
				function ogniFrame(event:Event) {
						 // tolgo lo scudo quando il video e' caricato
						 if((ns.bytesLoaded >= ns.bytesTotal) && scudorimosso==0){
							removeChild (scudo1);
							scudorimosso=1;
						 }
						 if(MyGlobal.playerstatus==0){
							 _play.alpha=1;
							 _stop.alpha=.4;
							 //trace('alpha=100');
						 }else{
							 _play.alpha=.4;
							 _stop.alpha=1;
							 //trace('alpha=60');
						 }
						 
						 MyGlobal.ora=int(ns.time);
						 minuti=Math.floor(MyGlobal.ora/60);
						 secondi=MyGlobal.ora-(minuti*60);
						 if(secondi<10)stringadaag='0' else stringadaag='';
						 tempo.text=minuti+":"+stringadaag+secondi+" ("+MyGlobal.ora+"/"+MyGlobal.duratavideo+")";
						 
						 
						 
						 // CONTROLLO SE SIAMO AD UN CUE POINT
						 
						 if(MyGlobal.ora==MyGlobal.punti[MyGlobal.puntoattuale]){
							 MyGlobal.puntoattuale++;
							 
							 testolez.multiline = true;
							 testolez.wordWrap = true;
							 testolez.selectable = false;  
							 testolez.htmlText=MyGlobal.testi[MyGlobal.puntoattuale];	
							 testolez.setTextFormat(myFormat3);		
							 
							
							 if(MyGlobal.filesext[MyGlobal.puntoattuale].indexOf("1-1.jpg") >= 0){
								 // ho trovato il video carico l immagine ma vado anche al video
								 if(MyGlobal.filesext[MyGlobal.puntoattuale]){
										loadImage("immagini/"+MyGlobal.filesext[MyGlobal.puntoattuale]); 
									} else {
										removeChildrenOf(cont1);
										loadImage("immagini/avatarfadrsi.jpg");
								 }
								
								// aggiungere bottone riprendi lezione dopo video
								
								
								// fermo il video e carico youtube
								
								 ns.pause();
								 MyGlobal.playerstatus=0;
								 var r:URLRequest = new URLRequest("javascript:mostrayoutube();");
								 navigateToURL(r,'_self');
								 
								 
							 }else{
								 // si tratta di una immagine esterna da caricare
							 
								 if(MyGlobal.filesext[MyGlobal.puntoattuale]){
										loadImage("immagini/"+MyGlobal.filesext[MyGlobal.puntoattuale]); 
									} else {
										removeChildrenOf(cont1);
										loadImage("immagini/avatarfadrsi.jpg");
								 }
							 }

						 }
						 
						 if(MyGlobal.playerstatus==0){
							 _play.alpha=1;
							 _stop.alpha=.4;
							 //trace('alpha=100');
						 }else{
							 _play.alpha=.4;
							 _stop.alpha=1;
							 //trace('alpha=60');
						 }
						 
						 
				}
				
				////////////////// TEXT FIELDS - titolo , tempo, testi
				
				
				var myFormat:TextFormat = new TextFormat();
				myFormat.align = "center";
				myFormat.color = 0x000000;   
				myFormat.size = 24; 
				
				var titolo:TextField = new TextField();  
				addChild(titolo);   
				titolo.text = MyGlobal.titololezione;   
				titolo.x = 35;  
				titolo.y = 20;  
				titolo.height=30;
				titolo.width=570;				
				titolo.selectable = false;  
				titolo.setTextFormat(myFormat); 
				
				var myFormat2:TextFormat = new TextFormat();  
				myFormat2.color = 0xAA0000;   
				myFormat2.size = 24;  
				
				var tempo:TextField = new TextField();  
				addChild(tempo);   
				tempo.text = "0";   
				tempo.x = 25;  
				tempo.y = 265;  
				tempo.selectable = false;  
				tempo.autoSize = TextFieldAutoSize.LEFT;  
				tempo.setTextFormat(myFormat2); 
				
				var myFormat3:TextFormat = new TextFormat();  
				myFormat3.color = 0x000000;   
				myFormat3.size = 13;  
				
				var testolez:TextField = new TextField();  
				addChild(testolez);   
				testolez.x = 35;  
				testolez.y = 300;  
				testolez.width=560;
				testolez.height=80;
				testolez.multiline = true;
				testolez.wordWrap = true;
				testolez.selectable = false;  
				testolez.htmlText = MyGlobal.testi[0]; 
				testolez.setTextFormat(myFormat3);

				
				
				/////////////////// CARICO LA PRIMA IMMAGINE
				
				
				if(MyGlobal.filesext[MyGlobal.puntoattuale]){
										loadImage("immagini/"+MyGlobal.filesext[MyGlobal.puntoattuale]); 
				} else {
										loadImage("immagini/avatarfadrsi.jpg");
				}

				
				////////////////// BOTTONI
				
				var _play:playBTN = new playBTN();
				_play.x = 80;
				_play.y = 440;
				_play.name = "bottoneplay";
				
				addChild(_play);
				
				_play.addEventListener(MouseEvent.CLICK, playBtnClick);
				
				var _stop:stopBTN = new stopBTN();
				_stop.x = 160;
				_stop.y = 440;
				_stop.name = "bottonestop";
				
				addChild(_stop);
				
				_stop.addEventListener(MouseEvent.CLICK, stopBtnClick);
				
				// bottoni vai a punto lezione
				function testBClick (evt:Event){
					var z:URLRequest = new URLRequest("javascript:faitest('"+MyGlobal.idl+"','"+MyGlobal.ids+"')");;
					navigateToURL(z,'_self');
				}
				
				function cueBClick (evt:Event){
					trace(evt.target.ID + " " + evt.target.testo+ " " + evt.target.tempo);
					ns.seek(evt.target.tempo);
					MyGlobal.puntoattuale=evt.target.ID;
					testolez.htmlText=MyGlobal.testi[MyGlobal.puntoattuale];
					testolez.setTextFormat(myFormat3);
					
					if(MyGlobal.filesext[MyGlobal.puntoattuale].indexOf("http") >= 0){
								 var r:URLRequest = new URLRequest("javascript:mostrayoutube();");
								 navigateToURL(r,'_self');
								 ns.pause();
								 
					 }else{
								 // si tratta di una immagine esterna da caricare
							 
								 if(MyGlobal.filesext[MyGlobal.puntoattuale]){
										loadImage("immagini/"+MyGlobal.filesext[MyGlobal.puntoattuale]); 
									} else {
										removeChildrenOf(cont1);
										loadImage("immagini/avatarfadrsi.jpg");
								 }
					 }


					
				}
				
				// il primo tasto che deve portare all'inizio della lezione
				var cueA:cueBTN = new cueBTN();
				cueA.x = 300;
				cueA.y = 440;
				cueA.ID = 0;
				cueA.name = "primotasto";
				cueA.testo = MyGlobal.testi[0];
				trace(MyGlobal.testi[0]);
				cueA.tempo= 0;
				cueA.addEventListener(MouseEvent.CLICK,cueBClick);
				addChild (cueA);
				
				for(var j=0;j<MyGlobal.numeropunti;j++){
					trace(j);
					
					var cueB:cueBTN = new cueBTN();
					cueB.x = 320 + j * 10;
					cueB.y = 440;
					cueB.ID = j+1;
					cueB.name = "b"+j;
					cueB.testo = MyGlobal.testi[j];
					cueB.tempo= MyGlobal.punti[j];
					cueB.addEventListener(MouseEvent.CLICK,cueBClick);
					addChild (cueB);
					
				}
				
				// inserisco lo scudo che va tolto alla fine
				var scudo1:scudo = new scudo();
				scudo1.y=440;
				scudo1.x=320;
				addChild (scudo1);
				
				////// VIDEO BTN FUNCTIONS  //////
				function playBtnClick(event:MouseEvent):void
				{
					ns.resume();
					MyGlobal.playerstatus=1;
				}
				
				function stopBtnClick(event:MouseEvent):void
				{
					ns.pause();
					MyGlobal.playerstatus=0;
				}
				
			}

		}
	}
	
}
