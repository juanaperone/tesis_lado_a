import processing.video.*; // Importar la librería de video para usar videos en Processing
import java.util.ArrayList; // Importar la clase ArrayList para manejar listas de elementos
import java.util.Random; // Importar la clase Random para generar números aleatorios

// Clase que representa un mensaje con tiempo limitado en pantalla
class TimedMessage {
    String user; // Nombre del usuario que envió el mensaje
    String text; // El contenido del mensaje
    int timer; // Duración en fotogramas que el mensaje estará en pantalla
    float x, y; // Posiciones x e y en la pantalla donde se muestra el mensaje

    // Constructor que inicializa el mensaje, la duración y el usuario
    TimedMessage(String text, int duration) {
        this.text = text;
        this.timer = duration;
        this.user = generateRandomUser(); // Genera un nombre de usuario aleatorio
        setRandomPosition(); // Asigna una posición aleatoria para el mensaje
    }

    // Asigna una posición aleatoria dentro de los márgenes de la pantalla
    void setRandomPosition() {
        x = random(10, width - 250); // Random dentro del ancho de la pantalla menos 250 px de margen
        y = random(40, height - 240); // Random dentro del alto de la pantalla menos 240 px de margen
    }

    // Reduce el tiempo de vida del mensaje en 1 fotograma
    void update() {
        timer--;
    }

    // Verifica si el tiempo del mensaje ya ha terminado
    boolean isExpired() {
        return timer <= 0; // Si el timer llega a 0, el mensaje ha expirado
    }

    // Genera un nombre de usuario aleatorio en formato @user1234
    String generateRandomUser() {
        Random rand = new Random(); // Crea una instancia de Random
        int userNumber = rand.nextInt(9999); // Genera un número aleatorio entre 0 y 9999
        return "@user" + userNumber; // Devuelve el nombre en formato @user1234
    }
}

// Declaración de variables globales
Movie video; // Variable para manejar el video
ArrayList<TimedMessage> messages; // Lista para almacenar mensajes con tiempo limitado
int messageDuration = 1200; // Duración de cada mensaje en fotogramas
PFont tweetFont; // Fuente para los mensajes
String currentMessage = ""; // Mensaje que el usuario está escribiendo actualmente

// Preguntas aleatorias que se muestran en la pantalla
String[] questions = {
    "¿Qué pensás vos?", 
    "¿Qué te genera esto?", 
    "¿Cuál es tu opinión?", 
    "¿Qué está pasando?", 
    "¿Qué opinas sobre el cine argentino?", 
    "¿Cómo te sentís al respecto?"
};
int currentQuestionIndex; // Índice actual de la pregunta que se muestra

ArrayList<Float[]> occupiedPositions; // Lista para almacenar las posiciones ocupadas por mensajes

void setup() {
    fullScreen(); // Modo pantalla completa
    surface.setResizable(false); // Desactivar la capacidad de redimensionar la ventana

    video = new Movie(this, "lado_a.mov"); // Cargar el video
    video.loop(); // Hacer que el video se reproduzca en bucle

    messages = new ArrayList<TimedMessage>(); // Inicializar la lista de mensajes
    occupiedPositions = new ArrayList<Float[]>(); // Inicializar la lista de posiciones ocupadas
    tweetFont = createFont("Helvetica", 14); // Crear la fuente que se usará para los textos
    textFont(tweetFont); // Aplicar la fuente al texto

    currentQuestionIndex = (int)random(questions.length); // Elegir una pregunta aleatoria para mostrar
}

void draw() {
    background(21, 32, 43); // Fondo oscuro similar al modo oscuro de Twitter

    image(video, 0, 0, width, height - 200); // Dibujar el video en la pantalla, dejando un espacio al final

    // Dibujar todos los mensajes en pantalla
    for (TimedMessage msg : messages) {
        fill(25, 39, 52, 220); // Fondo de mensaje semi-transparente
        stroke(29, 161, 242); // Bordes de color azul similar al de Twitter
        strokeWeight(2); // Grosor del borde

        float msgWidth = textWidth(msg.user + ": " + msg.text) + 40; // Ancho del mensaje basado en el texto
        msgWidth = constrain(msgWidth, 0, width - 20); // Limitar el ancho del mensaje para que no exceda la pantalla

        rect(msg.x - 10, msg.y - 30, msgWidth, 50, 5); // Dibujar un rectángulo de fondo para el mensaje

        fill(255); // Texto blanco
        textAlign(LEFT); // Alinear el texto a la izquierda
        text(msg.user + ": " + msg.text, msg.x + 10, msg.y); // Dibujar el texto del usuario y el mensaje

        msg.update(); // Actualizar el estado del mensaje (reducir el timer)
    }

    messages.removeIf(msg -> msg.isExpired()); // Eliminar mensajes que ya expiraron

    float inputWidth = width * 0.5; // Definir el ancho del área de entrada como la mitad de la pantalla
    fill(25, 39, 52); // Fondo oscuro para el área de escritura
    noStroke(); // Sin bordes
    rect((width - inputWidth) / 2 + 10, height - 200, inputWidth - 20, height - 140, 5); // Dibujar el área de entrada

    fill(255); // Texto blanco
    textSize(24); // Tamaño de fuente grande para las preguntas
    textAlign(CENTER); // Centrar el texto
    text(questions[currentQuestionIndex], width / 2, height - 170); // Mostrar la pregunta actual en la pantalla

    textSize(16); // Reducir el tamaño de la fuente para el mensaje en curso
    text(currentMessage, width / 2 - textWidth(currentMessage) / 2, height - 95); // Dibujar el mensaje que el usuario está escribiendo

    // Área de escritura (fondo para el texto que se escribe)
    float writeAreaHeight = 40;
    fill(255); 
    noStroke();
    rect((width - inputWidth) / 2 + 10, height - writeAreaHeight - (height - video.height), inputWidth - 20, writeAreaHeight, 5);

    // Línea indicadora de escritura
    stroke(150);
    strokeWeight(1);
    line((width - inputWidth) / 2 + 10, height - writeAreaHeight - (height - video.height) + writeAreaHeight + 5, 
         (width + inputWidth) / 2 - 10, height - writeAreaHeight - (height - video.height) + writeAreaHeight + 5);

    // Barra que titila como cursor
    float cursorX = width / 2 + textWidth(currentMessage) / 2 + 5;
    float cursorY = height - 95;

    // Mostrar el cursor de texto que titila cada medio segundo
    if ((frameCount / 30) % 2 == 0) {
        fill(255);
        rect(cursorX, cursorY - 10, 2, 20); // Dibujar el cursor vertical
    }
}

// Función que maneja la escritura del usuario
void keyTyped() {
    if (key != ENTER && key != RETURN && key != BACKSPACE) { // Agregar la tecla al mensaje si no es Enter o Backspace
        currentMessage += key;
    }
}

// Función que maneja la presión de teclas específicas
void keyPressed() {
    if (key == BACKSPACE && currentMessage.length() > 0) { // Si el usuario presiona Backspace, eliminar la última letra
        currentMessage = currentMessage.substring(0, currentMessage.length() - 1);
    } else if (key == ENTER || key == RETURN) { // Si el usuario presiona Enter, se envía el mensaje
        if (currentMessage.length() > 0) {
            // Limitar la longitud del mensaje a 100 caracteres
            TimedMessage newMsg = new TimedMessage(currentMessage.length() > 100 ? currentMessage.substring(0, 100) : currentMessage, messageDuration);
            
            // Agregar el mensaje si no se superpone con otros
            if (!isOverlapping(newMsg)) {
                messages.add(newMsg); // Agregar el mensaje a la lista
                occupiedPositions.add(new Float[]{newMsg.x, newMsg.y}); // Marcar la posición como ocupada
                currentQuestionIndex = (int)random(questions.length); // Cambiar la pregunta aleatoriamente
            }
            
            currentMessage = ""; // Reiniciar el mensaje actual
        }
    }
}

// Función que verifica si el nuevo mensaje se superpone con uno existente
boolean isOverlapping(TimedMessage newMsg) {
    for (Float[] pos : occupiedPositions) {
        float existingX = pos[0]; // Posición x de un mensaje existente
        float existingY = pos[1]; // Posición y de un mensaje existente
        
        // Verificar si la distancia entre los mensajes es menor a 50 (evita solapamientos)
        if (dist(newMsg.x, newMsg.y, existingX, existingY) < 50) {
            return true; // Si se superponen, devolver true
        }
    }
    return false; // No se superponen
}

// Función que lee los frames del video
void movieEvent(Movie m) {
    m.read(); // Leer los frames del video
}
