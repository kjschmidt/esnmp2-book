public class SnmpTrap {

	SnmpUtil _util = null;

	public SnmpTrap(String host, String varbind, int type){
		_util = new SnmpUtil(host,varbind,false,type);
	}

	public SnmpTrap(String host, String varbind, int type, String user, String authProtocol, 
		  String authPasshrase, String privProtocol, String privPassphrase) {
		  _util = new SnmpUtil(host,varbind,user,authProtocol,authPasshrase,privProtocol,privPassphrase,false,type);
	}

	public void doTrap() {
		_util.sendAndProcessResponse();
	}

}
