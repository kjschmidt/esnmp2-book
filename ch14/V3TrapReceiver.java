public class V3TrapReceiver {

	private SnmpUtil _util = null;

	public V3TrapReceiver(String host, String user, String authProto, String authPass,
			String privProto,String privPass) {
		_util = new SnmpUtil(host,null,user,authProto,authPass,privProto,privPass,true,0);
	}

	public void listen() {
		_util.listen();
	}
}
