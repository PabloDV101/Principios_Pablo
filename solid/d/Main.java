public class Main{
public static void main(String [] args){
Dispositivo bombilla = new Bombilla();
Interruptor interruptor = new Interruptor(bombilla);

interruptor.presionar();
}
}
