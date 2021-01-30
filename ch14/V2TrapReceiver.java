public class V2TrapReceiver {

	SnmpUtil _util = null;

	public V2TrapReceiver(String host) {
		_util = new SnmpUtil(host,null,true,0);
	}

	public void listen() {
		_util.listen();
	}
}
