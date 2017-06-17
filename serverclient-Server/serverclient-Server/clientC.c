//
//  main.m
//  server-client
//
//  Created by codew on 2017/6/16.
//  Copyright © 2017年 codew. All rights reserved.
//

#include <sys/socket.h>
#include <unistd.h>
#include <sys/types.h>
#include <stdlib.h>
#include <stdio.h>
#include <errno.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <string.h>

#define ERR_EXIT(m)\
do\
{\
perror(m);\
exit(EXIT_FAILURE);\
}while(0)\

int main(void) {
    
    // 1. 创建套接字----man socket
    int socketClient;
    /**
     AF_INET ---IPV4
     AF_INET6 ---IPV6
     
     PF_INET和AF_INET值是一样的, P-protocol f-family INE网际协议
     
     PF_INET, SOCK_STREAM 这两个决定了是TCP协议---然后第三个参数习惯上是0, 亦可以指定它索要的协议
     第三个参数0表示自动,网际加流式一定是TCP所以可以不填
     */
    
    socketClient = socket(PF_INET, SOCK_STREAM, IPPROTO_TCP);
    
    if (socketClient < 0) {
        //        NSLog(@"失败");
        ERR_EXIT("socket");
    }
    
    // 2. 绑定一个地址----绑定一个电话号码-----地址初始化
    struct sockaddr_in servaddr;
    memset(&servaddr, 0, sizeof(servaddr));// 初始化地址
    
    servaddr.sin_family = AF_INET;
    servaddr.sin_port = htons(5189);
    servaddr.sin_addr.s_addr = inet_addr("162.243.64.148");
    
    
    // 客户端不需要绑定
    // 也不需要监听
    
    /**
     
     int connect(int socketfd, const struct sockaddr * addr, socklen_t addrlen)
     
     */
    
    int connectResult = connect(socketClient, (struct sockaddr *)&servaddr, sizeof(servaddr));
    if (connectResult < 0) {
        // 连接失败
        ERR_EXIT("connect error......");
    }
    char sendbuf[1024] = {0};
    char recvbuf[1024] = {0};
    
    // 从标准输入接收一行数据.  不等于空
    char * msgbuf = fgets(&sendbuf, sizeof(sendbuf), stdin);
    while (msgbuf != NULL) {
        write(socketClient, sendbuf, strlen(sendbuf));
        
        read(socketClient, recvbuf, sizeof(recvbuf));
        
        fputs(recvbuf, stdout);
    }
    
    close(socketClient);
    
    return 0;
}
