# BackandAS3API
Simple AS3 API call to fetch data from backand.com


Usage
private var bapi:BackandAPI = new BackandAPI("KEY","APP_NAME");

bapi.getData(BackandAPI.TYPE_KEY , "CLASS_PATH", URLRequestMethod.GET, {pageSize:10,pageNumber:1},null,httpRequest,httpFault);

public function httpRequest( response:* ):void
{
	trace("httpRequest",response)
}
public function httpFault( error:* ):void
{
	trace("httpFault", error )
}
