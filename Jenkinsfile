pipeline {
    agent any

    stages {
        stage('Fetch Code') {
            steps {
               checkout scm
            }
        }
        stage('Build') {
            steps {
                sh 'cd /home/juan/buildroot/14A1'
		sh 'echo "Estoy en: $(pwd)"'
		sh '/home/juan/buildroot/output/host/usr/bin/arm-linux-gcc -o main main.c -static'
            }
        }
        stage('Deploy on Board') {
            steps {
                // Beispiel für das Übertragen der Build-Artefakte
                sh 'scp main root@192.168.2.115:/root/14A1'
            }
        }
        stage('Test') {
            steps {
                // Beispiel für das Ausführen automatisierter Tests
		sh 'scp test.sh root@192.168.2.115:/root/14A1/tests'
                sh 'ssh root@192.168.2.115 "cd /root/14A1/tests && ./test.sh"'
            }
        }
        stage('Code Integration') {
            steps {
                // Beispiel für das Zusammenführen der getesteten Software in
den Hauptzweig
                sh 'git merge'
            }
        }
	stage('Deployment') {
            steps {
                // Automatisierte Bereitstellung und Monitoring
                sh 'ssh root@192.168.2.115 "cd /root/14A1/ && ./main &"'
            }
        }
        stage('Monitoring') {
            steps {
                // Monitoring-Schritt (Beispiel: Prüfen der Systemlogs)
                sh 'ssh root@192.168.2.115 "tail -f /var/log/syslog"'
            }
        }
    }
	post {
	always {
            archiveArtifacts artifacts: 'build/**', fingerprint: true
        }
        failure {
	    // Rollback im Falle eines Fehlers
	    echo '❌ Error: Build o test falló.'
	    sh 'scp rollback.sh root@192.168.2.115:/root/14A1'
            sh 'ssh root@192.168.2.115 "bash /root/14A1/rollback.sh"'
        }
	success {
            echo '✅ Éxito: Build y test correctos.'
        }
    }
}
