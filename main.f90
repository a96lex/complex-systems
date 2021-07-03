program main
    implicit none
    integer, dimension (:), allocatable :: infected_list_pointer, neighbours, pointer_i, pointer_f, cardinality,  infected_list
    integer, dimension (:,:), allocatable :: active_links
    integer :: N = 0, E = 0, node1, node2, n_links 
    integer :: iostat, i, ioerror, total_iterations
    character (len=100) :: filename, cmd_arg
    double precision :: initial_infected_rate, lambda, delta, time
    common /parameters/ lambda, delta

    ! Checking for correct code usage
    if (command_argument_count().ne.5) then
        print*, "Command line argument count is different than 5. Check readme.md to learn how to properly use this code"
        stop
    endif
    
    ! Getting arguments from command line
    call get_command_argument(1,cmd_arg)
    filename = cmd_arg
    call get_command_argument(2,cmd_arg)
    read(cmd_arg,*,iostat=iostat) initial_infected_rate
    if (iostat.ne.0) ioerror = iostat
    call get_command_argument(3,cmd_arg)
    read(cmd_arg,*,iostat=iostat) lambda
    if (iostat.ne.0) ioerror = iostat
    call get_command_argument(4,cmd_arg)
    read(cmd_arg,*,iostat=iostat) delta
    if (iostat.ne.0) ioerror = iostat
    call get_command_argument(5,cmd_arg)
    read(cmd_arg,"(i8)",iostat=iostat) total_iterations
    if (iostat.ne.0) ioerror = iostat

    ! Check for input errors
    if (ioerror.ne.0) then
        print*, ioerror
        print*, "At least one of the command line arguments is wrong. Check readme.md to learn how to properly use this code"
        stop
    endif

    ! Use ms of CPU clock as seed
    call cpu_time(time)
    call srand(int(time*1e7))
    
    open (unit = 1, file = filename, status = "old", action = "read")
    open (unit = 2, file = "sir.out", action = "write")

    ! Find N and E
    do
        read(unit = 1, fmt = *, iostat = iostat) node1, node2
        if (iostat .ne. 0) exit

        if (node1 > N) N = node1
        if (node2 > N) N = node2
        E = E +1
    enddo

    ! Allocate vectors
    allocate(neighbours(2*E), infected_list_pointer(2*E))
    allocate(active_links(2,2*E))
    allocate(pointer_i(N), pointer_f(N), cardinality(N) ,infected_list(N))

    ! Find cardinality of all nodes
    rewind(unit = 1)
    cardinality = 0
    do
        read(unit = 1, fmt = *, iostat = iostat)  node1, node2
        if (iostat .ne. 0) exit 
        cardinality(node1) = cardinality(node1)+1
        cardinality(node2) = cardinality(node2)+1
    enddo   

    ! Construct pointer vectors
    pointer_i(1) = 1
    pointer_f(1) = cardinality(1)

    do i = 2, N
        pointer_i(i) = pointer_f(i-1) + 1
        pointer_f(i) = pointer_f(i-1) + cardinality(i) 
    enddo

    ! Infectate random agents
    infected_list = 0

    ! S = 0, I = 1, R = 2 
    do i = 1, N
        if(rand() < initial_infected_rate) then
            infected_list(i) = 1
        endif
    enddo


    ! Construct main vector
    neighbours = 0
    active_links = 0
    infected_list_pointer = 0
    pointer_f = pointer_i - 1
    n_links = 1
    rewind(unit = 1)

    ! Save active links to neighbours
    do
        read(unit = 1, fmt = *, iostat = iostat)  node1, node2
        if (iostat .ne. 0) exit
        pointer_f(node1) = pointer_f(node1) + 1
        pointer_f(node2) = pointer_f(node2) + 1
        neighbours(pointer_f(node1)) = node2 
        neighbours(pointer_f(node2)) = node1 
        ! The link is active only if one node is S and the other is I
        if (infected_list(node1).eq.0.and.infected_list(node2).eq.1) then
            active_links(n_links,1) = node2
            active_links(n_links,2) = node1
            infected_list_pointer(pointer_f(node2)) = n_links 
            n_links = n_links + 1
        endif
        if (infected_list(node1).eq.1.and.infected_list(node2).eq.0) then
            active_links(n_links,1) = node2
            active_links(n_links,2) = node1
            infected_list_pointer(pointer_f(node1)) = n_links 
            n_links = n_links + 1
        endif
    enddo

    ! Perform Gillespie algorithm simulation
    do i = 1, total_iterations
        call time_step_gillespie(E, N, neighbours, pointer_i, pointer_f, infected_list, n_links, infected_list_pointer)
    enddo

    ! Close all i/o files
    close(unit = 1)
    close(unit = 2)

end program main
 
subroutine time_step_gillespie(E, N , neighbours, pointer_i, pointer_f, infected_list, n_links, infected_list_pointer)
    implicit none
    integer :: E, N, neighbours(2*E), pointer_i(N), pointer_f(N), infected_list(N), infected_list_pointer(2*E), active_links(2,2*E)
    integer :: i, n_links, status_count(3) 
    double precision :: lambda, delta, prob_inf, prob_rec
    common /parameters/ lambda, delta

    ! Count status of all nodes (S = 0, I = 1, R = 2 )
    status_count = 0
    do i=1,N
        status_count(infected_list(i)+1) = status_count(infected_list(i)+1) +1 
    enddo
    
    ! Write count to file
    write(2,*)status_count

    ! Compute infection and recovery probabilities
    prob_rec = status_count(2) * delta / ( status_count(2) * delta + n_links * lambda )
    prob_inf = n_links * lambda / ( n_links * lambda + status_count(2) * delta )

    ! Loop through all nodes
    do i = 1, N
        ! If susceptible, try to infect
        if (infected_list(i).eq.0.and.n_links.gt.1) then
            if (rand() < prob_inf) then
                 infected_list(i) = 1
                call update_active_link_list(E, N, neighbours, pointer_i, pointer_f, &
                     infected_list, active_links, infected_list_pointer, n_links, i, .true.)
            endif
       ! If infected, try to recover
        elseif (infected_list(i).eq.1.and.n_links.gt.1) then
            if (rand() < prob_rec) then
                 infected_list(i) = 2
                call update_active_link_list(E, N, neighbours, pointer_i, pointer_f, &
                     infected_list, active_links, infected_list_pointer, n_links, i, .false.)
            endif
        endif   
    enddo

end subroutine time_step_gillespie


subroutine update_active_link_list(E, N, neighbours, pointer_i, pointer_f, &
     infected_list, active_links, infected_list_pointer, n_links, index, is_infected)
    implicit none
    integer :: E, N, neighbours(2*E), pointer_i(N), pointer_f(N), infected_list(N) 
    integer :: active_links(2,2*E), infected_list_pointer(2*E), index, i, n_links
    logical :: is_infected

    if (is_infected) then 
        do i = pointer_i(index), pointer_f(index)
            if (infected_list(i).eq.0) then
                active_links(1,n_links) = index
                active_links(2,n_links) = neighbours(i)
                infected_list_pointer(i) = n_links
                n_links = n_links + 1
            endif
        enddo
    else
        do i = pointer_i(index), pointer_f(index)
            if (infected_list_pointer(i).ne.0) then
                active_links(:,infected_list_pointer(i)) = active_links(:,n_links)
                active_links(:,n_links) = 0
                n_links = n_links - 1
            endif
        enddo
    endif

end subroutine update_active_link_list
