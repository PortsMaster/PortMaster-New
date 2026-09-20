from PySide import QtGui
from PySide.QtGui import QFileDialog, QMessageBox
from PySide.QtCore import Qt, QTimer, QCoreApplication, QSize
import Queue

class MainWidget(QtGui.QWidget):
    def __init__(self, process, input_queue, output_queue):
        super(MainWidget, self).__init__()
        self.done = False
        layout = QtGui.QVBoxLayout()

        logo = QtGui.QLabel()
        logo.setPixmap('./data/logo.png')
        logo.setAlignment(Qt.AlignVCenter | Qt.AlignHCenter)
        layout.addWidget(logo)

        status_list = self.status_list = QtGui.QListWidget()
        status_list.addItem('Chowdren, the blazingly fast runtime for '
                            'Clickteam Fusion.')
        status_list.addItem(u'Copyright (c) Mathias K\xe6rlev 2012-2015.')
        status_list.addItem('Applications made with Chowdren are subject to '
                            'the GNU General Public License.')

        layout.addWidget(status_list)

        self.setLayout(layout)

        timer = QTimer(self)
        timer.setInterval(100)
        timer.timeout.connect(self.process_console)
        timer.start()

        self.process = process
        self.output_queue = output_queue
        self.input_queue = input_queue

        self.log = open('chowdrenlog.txt', 'wb')

    def sizeHint(self):
        return QSize(1000, 600)

    def close(self):
        self.log.close()

        self.output_queue.put(None)
        self.process.join()
        self.output_queue.close()

    def process_console(self):
        try:
            while True:
                cmd, data = self.input_queue.get_nowait()
                if cmd == 'console':
                    for line in data:
                        self.status_list.addItem(line)
                        self.log.write(line + '\r\n')
                    self.status_list.scrollToBottom()
                elif cmd == 'result':
                    self.done = True
                    if data:
                        self.close()
                        QCoreApplication.instance().quit()
                        return
                    QMessageBox.critical(self, 'Build failed',
                                         'Build failed. Please check the '
                                         'build log.')
                    pass
        except Queue.Empty:
            return

class MainWindow(QtGui.QMainWindow):
    def __init__(self, *arg):
        super(MainWindow, self).__init__()
        self.setWindowTitle('Chowdren exporter')
        self.widget = MainWidget(*arg)
        self.setCentralWidget(self.widget)
        self.setWindowIcon(QtGui.QIcon('./data/icon.png'))

    def closeEvent(self, event):
        if not self.widget.done:
            event.ignore()
            return
        event.accept()
        self.widget.close()
