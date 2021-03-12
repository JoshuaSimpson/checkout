[
  {
    "name": "${service_name}",
    "image": "${image}:latest",
    "essential": true,
    "cpu": 10,
    "memory": 512,
    "links": [],
    "portMappings": [
      {
        "containerPort": 3000,
        "hostPort": 0,
        "protocol": "tcp"
      }
    ],
    "environment": [

    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "/ecs/${service_name}",
        "awslogs-stream-prefix": "${service_name}-log-stream",
        "awslogs-region": "${region}"
      }
    }
  }
]