1;

pkg load control;
pkg load symbolic;

##**************************************************************************
##*                OCTAVE PROGRAMMING (e-Yantra)
##*                ====================================
##*  This software is intended to teach Octave Programming and Mathematical
##*  Modeling concepts
##*  Theme: Lunar Scout
##*  Filename: Task_1A.m
##*  Version: 1.0.0
##*  Date: 18/09/2023
##*
##*  Team ID :LS_2978
##*  Team Leader Name:Abhishek Kumar
##*  Team Member Name  :Aman Sharma,Anurag Kumar, Badal Kumar
##*
##*
##*  Author: e-Yantra Project, Department of Computer Science
##*  and Engineering, Indian Institute of Technology Bombay.
##*
##*  Software released under Creative Commons CC BY-NC-SA
##*
##*  For legal information refer to:
##*        http://creativecommons.org/licenses/by-nc-sa/4.0/legalcode
##*
##*
##*  This software is made available on an �AS IS WHERE IS BASIS�.
##*  Licensee/end user indemnifies and will keep e-Yantra indemnified from
##*  any and all claim(s) that emanate from the use of the Software or
##*  breach of the terms of this agreement.
##*
##*  e-Yantra - An MHRD project under National Mission on Education using
##*  ICT(NMEICT)
##*
##**************************************************************************

## Function : Jacobian_A_B()
## ----------------------------------------------------
## Input:   Mp                - mass of the pendulum
##          l                 - Length of Pendulum
##          g                 - Acceleration due to gravity
##          Ma                - mass of the arm
##          Rp                - length of pendulum base from the pivot point
##          Ra                 - length from arm's center of mass to arm's pivot point
##          I_arm             - Moment of inertia of the arm in yaw angle
##          I_pendulum_theta  - Moment of inertia of the pendulum in tilt angle
##          I_pendulum_alpha  - Moment of inertia of the pendulum in yaw angle
##
## Output:  A - A matrix of system (State or System Matrix )
##          B - B matrix of system (Input Matrix)
##
## Purpose: Use jacobian function to find A and B matrices(State Space Model) in this function.

function [A,B] = Jacobian_A_B(Mp,l,g,Ma,Rp,Ra,I_arm,I_pendulum_theta,I_pendulum_alpha)

  alpha = sym('alpha');
  theta = sym('theta');
  theta_dot = sym('theta_dot');
  alpha_dot = sym('alpha_dot');
  u = sym('u');

  cos_theta = cos(theta);
  sin_theta = sin(theta);

  cos_alpha = cos(alpha);
  sin_alpha = sin(alpha);

  ########## ADD YOUR CODE HERE ################

 K1=I_pendulum_theta;
  K2=Mp*l*l;
  K3=Mp*Rp*l;
  K4=Mp*g*l;
  K5=I_arm;
  K6=Mp*Rp*Rp;
  K7=Mp*Rp*l;
 K8=Mp*Rp*l;
  M2=(K4*(K5+K6))/K3;
  M3=(K5+K6)*(K1+K2)/K3;

  theta_double_dot=(u-K7*sin_theta*theta_dot*theta_dot+M2*sin_theta)/(M3-K8*cos_theta*cos_theta);
  alpha_double_dot=(1/K3*cos_theta)*(((K1+K2)*(u-K7*sin_theta*theta_dot*theta_dot+M2*sin_theta)/(M3-K8*cos_theta*cos_theta)) - K4*sin_theta);
  theta_dot=theta_dot;
  alpha_dot=alpha_dot;

  x = [alpha_dot; alpha; theta_dot; theta];
  x_dot = [alpha_double_dot; alpha_dot; theta_double_dot; theta_dot];
  A_jaco=jacobian(x_dot,x);
  B_jaco=jacobian(x_dot,u);

  A = subs(A_jaco, {alpha_dot, alpha, theta_dot, theta}, {0, 0, 0, 0});
  B = subs(B_jaco, {alpha_dot, alpha, theta_dot, theta}, {0, 0, 0, 0});
  A=eval(A);
  B=eval(B);

  ##############################################
  A = double(A) ; # A should be (double) datatype
  B = double(B) ; # B should be (double) datatype

endfunction

## Function : lqr_Rotary_Inverted_Pendulum()
## ----------------------------------------------------
## Input:   A - A matrix of system (State or System Matrix )
##          B - B matrix of system (Input Matrix)
##
## Output:  K - LQR Gain Matrix
##
## Purpose: This function is used for finding optimal gains for the system using
##          the Linear Quadratic Regulator technique

function K = lqr_Rotary_Inverted_Pendulum(A,B)
  C    =  [1 0 0 0;
          0 1 0 0;
          0 0 1 0;
          0 0 0 1];           ## Initialise C matrix
  D     = [0;0;0;0];          ## Initialise D matrix
  Q     = [47 0 0 0;
           0 6000 0 0;
           0 0 5000 0;
           0 0 0 10000];           ## Initialise Q matrix
  R     = 1;                  ## Initialise R
  sys   = ss(A,B,C,D);  ## State Space Model
  sys_d = c2d(sys,0.01);
  K = dlqr(sys_d,Q,R)
  #K     = lqr(sys,Q,R);       ## Calculate K matrix from A,B,Q,R matrices using lqr()

endfunction

## Function : Rotary_Inverted_Pendulum_main()
## ----------------------------------------------------
## Purpose: Used for testing out the various controllers by calling their
##          respective functions.
##          (1) Tilt angle is represented as theta
##          (2) Yaw angle is represented as alpha

#function Rotary_Inverted_Pendulum_main()

  Mp = 0.5 ;                  # mass of the pendulum (Kg)
  l = 0.1 ;                  # length from pendulum's center of mass to pendulum's base/pivot (meter)
  g = 9.81 ;                  # Accelertion due to gravity (kgm/s^2)
  Ma = 0.25 ;                 # mass of the arm (kg)

  r_a = 0.01;                 # radius of arm cylinder (meter)
  r_p = 0.01;                 # radius of pendulum cylinder (meter)

  Rp = 0.30 ;                  # length from pendulum's base to arm's pivot point (meter)
  Ra = 0.15 ;                   # length from arm's center of mass to arm's pivot point (meter)

  I_arm = 0.006875;                   # Moment of inertia of the arm in yaw angle i.e. alpha (kgm^2)
  I_pendulum_theta = 0.00646;        # Moment of inertia of the pendulum in tilt angle i.e. theta (kgm^2)
  I_pendulum_alpha =0;        # Moment of inertia of the pendulum in yaw angle (kgm^2)

  [A,B] = Jacobian_A_B(Mp,l,g,Ma,Rp,Ra,I_arm,I_pendulum_theta,I_pendulum_alpha) ## find A , B matrix using  Jacobian_A_B() function
  K = lqr_Rotary_Inverted_Pendulum(A,B)  ## find the gains using lqr_Rotary_Inverted_Pendulum() function

#endfunction
