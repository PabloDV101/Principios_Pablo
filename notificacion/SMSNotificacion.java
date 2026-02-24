public class SMSNotificacion extends Notificacion implements Envia {
public SMSNotificacion(String mensaje,String destinatario){
	super(mensaje,destinatario);
}

@Override
public void enviar(){
	System.out.println("Enviando SMS al numero "+destinatario+" [Costo: $0.10]");
}

@Override
public void registrarLog(){
System.out.println("Log: Notificación creada para "+destinatario);
}
}
