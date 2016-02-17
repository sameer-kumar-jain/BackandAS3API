package
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;

	public class BackandAPI extends EventDispatcher
	{
		public static const TYPE_LOGIN:String = "TYPE_LOGIN";
		public static const TYPE_KEY:String = "TYPE_KEY"
		/*
		 * End Point 
		*/
		private var api:String = 'https://api.backand.com/';
		/*
		 *Temporary Key, normaly used for read only data
		*/
		private var key:String = 'YOUR_KEY';
		/*
		 * TYpe of request 
		*/
		private var type:String = 'application/json';
		/*
		 *Application name 
		*/
		private var f_appname:String;
		/*
		 * Authorised token if login provided 
		*/
		private var token:String;
		private var f_className:String;
		private var f_params:Object;
		private var f_where:Object;
		private var f_success:Function;
		private var f_error:Function;
		private var f_username:String;
		private var f_password:String; 
		private var f_method:String = URLRequestMethod.GET;
		
		public function BackandAPI( key:String, appname:String, username:String = null, password:String = null )
		{
			key = key;f_appname = appname;f_username = username; f_password = password;
		}
		/*
		 * @type = wheather using temporary key or login
		 * @login = details of username and password, required if using login type
		*/
		public function getData( type:String, className:String="", method:String = null, params:Object = null, where:Object = null, success:Function = null, error:Function = null ):void
		{
			if( type == TYPE_LOGIN )
			{
				getToken( className , method, params , where , success , error )
			}
			else
			{
				call( className , method , params , where , success , error )
			}
		}
		/*
		* Get Token in case we are providing username and password
		*/
		private function getToken( className:String="", method:String = null , params:Object = null, where:Object = null, success:Function = null, error:Function = null ):void
		{
			var ldr:URLLoader = new URLLoader();
			var req:URLRequest = new URLRequest( api + "token");
			var vars:URLVariables = new URLVariables();
			
			req.method = URLRequestMethod.POST
			
			vars.grant_type= "password";
			vars.username= f_username;
			vars.password= f_password;
			vars.appname= f_appname;
			req.data = vars;
			req.contentType = "application/x-www-form-urlencoded";
			ldr.addEventListener(Event.COMPLETE, function( e:Event ):void
			{
				var data:Object = JSON.parse( e.currentTarget.data);
				token = data.token_type + ' ' + data.access_token;
				call( className , method , params , where , success , error )
			}, false, 0, true);		
			if (error != null) { ldr.addEventListener(IOErrorEvent.IO_ERROR, error, false, 0, true); }
			ldr.load(req);
		}
		
		private function call(  className:String="", method:String = null , params:Object = null, where:Object = null, success:Function = null, error:Function = null ):void
		{
			var ldr:URLLoader = new URLLoader();
			var req:URLRequest = new URLRequest( api + className);
			
			if (where != null) {
				if (params == null) { params = {}; }
				params['where'] = JSON.stringify(where); 
			}
			
			if (params != null) { 
				if (method == URLRequestMethod.GET) {
					var vars:URLVariables = new URLVariables();
					for (var p:String in params) {
						vars[p] = params[p];
					}
					req.data = vars;
				} else { 
					req.data = JSON.stringify(params); 
				}
			}
			req.contentType = type;
			if(method)req.method = method;
			
			if( token )
			{
				req.requestHeaders.push(new URLRequestHeader('Authorization', token ));
			}
			else
			{
				req.requestHeaders.push(new URLRequestHeader('AnonymousToken', key ));
			}
			req.requestHeaders.push(new URLRequestHeader('AppName', 'snapshove' ));
			req.requestHeaders.push(new URLRequestHeader('Content-Type', type ));
			req.requestHeaders.push(new URLRequestHeader('Accept', type ));
			

			if (success != null) { 
				ldr.addEventListener(Event.COMPLETE, function (e:Event):void {
					var data:Object = JSON.parse(e.target.data);
					success(data);
				}, false, 0, true);
			}
			if (error != null) { ldr.addEventListener(IOErrorEvent.IO_ERROR, error, false, 0, true); }
			
			// Debug -----------------> 
			ldr.addEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, function (resp:HTTPStatusEvent):void { trace(resp); }, false, 0, true); 
			// <-----------------------
			ldr.dataFormat = URLLoaderDataFormat.TEXT
			ldr.load(req);
			
		}
	}
}
