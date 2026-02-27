class Interruptor{
private Dispositivo dispositivo;

public Interruptor(Dispositivo dispositivo){
this.dispositivo = dispositivo;
}
public void presionar(){
dispositivo.encender();
}
}
