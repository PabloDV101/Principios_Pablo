public class EmailNotificacion extends Notificacion implements Envia{

public EmailNotificacion(String mensaje, String destinatario){
super(mensaje,destinatario);

}

@Override
public void enviar(){
	System.out.println("Enviando Email a "+destinatario+": "+mensaje);
}
@Override
public void registrarLog(){
System.out.println("Log: Notificación creada para "+destinatario);
}
}

