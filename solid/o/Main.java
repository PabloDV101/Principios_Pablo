public class Main{
public static void main(String[]args){
	ProcesadorPago procesador = new ProcesadorPago();

	MetodoPago pago1 = new PagoTarjeta();
	MetodoPago pago2 = new PagoPayPal();

	procesador.procesar(pago1);
	procesador.procesar(pago2);

}

}
