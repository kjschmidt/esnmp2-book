public class MainSnmpV3Receiver{
	public MainSnmpV3Receiver(){

	}

	public static void main(String[] args){
		V3TrapReceiver v3 = new V3TrapReceiver("127.0.0.1","kschmidt","MD5",
			"mysecretpass","DES","mypassphrase");
		v3.listen();
	}
}

