program main
    implicit none
    integer, allocatable :: neighbours(:), pointer_i(:), pointer_f(:), cardinality(:)
    integer :: N = 0, E = 0
    integer :: node1, node2, n_links ! for reading input file
    integer :: iostat, i ! helper integers
    character (len=100) :: filename = "net1000.dat"
    !character (len=100) :: filename = "input.dat"

    double precision :: initial_infected_rate = .01
    integer, allocatable :: infected_list(:)

    ! print*, "Write the name of the input file"
    ! read (*, *) filename

    open (unit = 1, file = filename, status = "old", action = "read")
    open (unit = 2, file = "sir.out", action = "write")

    ! 1st input read: find N and E
    do
        read(unit = 1, fmt = *, iostat = iostat) node1, node2
        if (iostat .ne. 0) exit

        if (node1 > N) N = node1
        if (node2 > N) N = node2
        E = E +1

    enddo

    ! Allocate vectors
    allocate(neighbours(2*E), pointer_i(N), pointer_f(N), cardinality(N))


    ! Infectate random agents

    allocate(infected_list(N))

    infected_list = 0

    call srand(165)
    
    ! S = 0, I = 1, R = 2 
    do i = 1, N
        if(rand() < initial_infected_rate) then
            infected_list(i) = 1
        endif
    enddo

    do i = 1, 20

        call time_step_gillespie(E, N, neighbours, pointer_i, pointer_f, cardinality, infected_list, n_links)
    enddo

    close(unit = 1)
    close(unit = 2)

end program main
 
subroutine time_step_gillespie(E, N , neighbours, pointer_i, pointer_f, cardinality, infected_list, n_links)
    implicit none
    integer :: E, N, neighbours(2*E), pointer_i(N), pointer_f(N), cardinality(N), infected_list(N)
    integer :: iostat, node1, node2, i, n_links
    integer :: status_count(3) 
    double precision :: lambda, delta, prob_inf, prob_rec
    ! 2nd input read: find cardinality of all nodes
    rewind(unit = 1)
    cardinality = 0
    n_links = 0
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

    ! 3rd input read: construct main vector
    neighbours = 0
    pointer_f = pointer_i - 1
    rewind(unit = 1)

    do
        read(unit = 1, fmt = *, iostat = iostat)  node1, node2
        if (iostat .ne. 0) exit
        pointer_f(node1) = pointer_f(node1) + 1
        pointer_f(node2) = pointer_f(node2) + 1
        ! only if one node is S and the other is I
        if (infected_list(node1).eq.0.and.infected_list(node2).eq.1.or.infected_list(node1).eq.1.and.infected_list(node2).eq.0) then
            neighbours(pointer_f(node1)) = node2 
            neighbours(pointer_f(node2)) = node1 
            n_links = n_links + 1
        endif
    enddo

    status_count = 0

    do i=1,N
        !cosa = infected_list(i) ! puede ser = 0, 1 o 2
        status_count(infected_list(i)+1) = status_count(infected_list(i)+1) +1 
    enddo
    
    write(2,*)status_count
    print*,n_links

    lambda = 0.5
    delta = 0.5

    prob_rec = status_count(2) * delta / ( status_count(2) * delta + n_links * lambda )
    prob_inf = n_links * lambda / ( n_links * lambda + status_count(2) * delta )

    print*,status_count, n_links

    do i = 1, N
        if (infected_list(i).eq.0) then
            if (rand() < prob_inf) infected_list(i) = 1
        elseif (infected_list(i).eq.1) then
            if (rand() < prob_rec) infected_list(i) = 2
        endif
    enddo

end subroutine time_step_gillespie