public class MainSnmpV2Receiver{

	public MainSnmpV2Receiver( ){

	}

	public static void main(String[] args){
		V2TrapReceiver v2 = new V2TrapReceiver("127.0.0.1");
		v2.listen( );
	}
}
